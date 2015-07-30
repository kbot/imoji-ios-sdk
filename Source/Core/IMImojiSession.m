//
//  ImojiSDK
//
//  Created by Nima Khoshini
//  Copyright (C) 2015 Imoji
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import <Bolts/BFTaskCompletionSource.h>
#import <Bolts/BFTask.h>
#import <Bolts/BFExecutor.h>
#import "ImojiSDK.h"
#import "UIImage+Formats.h"
#import "NSDictionary+Utils.h"
#import "IMMutableImojiObject.h"
#import "UIImage+Extensions.h"
#import "IMMutableCategoryObject.h"
#import "BFTask+Utils.h"
#import "IMMutableImojiSessionStoragePolicy.h"
#import "NSArray+Utils.h"
#import "IMImojiSession+Private.h"

NSString *const IMImojiSessionErrorDomain = @"IMImojiSessionErrorDomain";

@implementation IMImojiSession

@synthesize sessionState = _sessionState;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupWithStoragePolicy:[IMImojiSessionStoragePolicy temporaryDiskStoragePolicy]];
    }

    return self;
}

- (instancetype)initWithStoragePolicy:(IMImojiSessionStoragePolicy *)storagePolicy {
    self = [super init];
    if (self) {
        [self setupWithStoragePolicy:storagePolicy];
    }

    return self;
}

- (void)setupWithStoragePolicy:(IMImojiSessionStoragePolicy *)storagePolicy {
    _sessionState = IMImojiSessionStateNotConnected;

    NSAssert([storagePolicy isKindOfClass:[IMMutableImojiSessionStoragePolicy class]], @"storage policy must be created with one of the factory methods (ex: temporaryDiskStoragePolicy)");

    _storagePolicy = storagePolicy;
    [self readAuthenticationCredentials];
}

- (BFTask *)downloadImojiContents:(IMMutableImojiObject *)imoji
                          quality:(IMImojiObjectRenderSize)quality
                cancellationToken:cancellationToken {
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    [[self validateSession] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error) {
            taskCompletionSource.error = task.error;
        } else {
            if ([(IMMutableImojiSessionStoragePolicy *) self.storagePolicy imojiExists:imoji quality:quality format:imoji.imageFormat]) {
                taskCompletionSource.result = imoji;
            } else if (!imoji.thumbnailURL || !imoji.fullURL) {
                taskCompletionSource.error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                                 code:IMImojiSessionErrorCodeImojiDoesNotExist
                                                             userInfo:@{
                                                                     NSLocalizedDescriptionKey : [NSString stringWithFormat:@"unable to download imoji %@", imoji.identifier]
                                                             }];
            } else {
                [self downloadImojiImageAsync:imoji
                                      quality:quality
                                   imojiIndex:0
                            cancellationToken:cancellationToken
                        imojiResponseCallback:^(IMImojiObject *imojiObject, NSUInteger index, NSError *error) {
                            if (error) {
                                taskCompletionSource.error = error;
                            } else {
                                taskCompletionSource.result = imojiObject;
                            }
                        }];
            }
        }

        return nil;
    }];

    return taskCompletionSource.task;
}

#pragma mark Public Methods

- (NSOperation *)getImojiCategoriesWithClassification:(IMImojiSessionCategoryClassification)classification
                                             callback:(IMImojiSessionImojiCategoriesResponseCallback)callback {
    NSOperation *cancellationToken = self.cancellationTokenOperation;
    NSString *classificationParameter = [IMImojiSession categoryClassifications][@(classification)];

    [[self runValidatedGetTaskWithPath:@"/imoji/categories/fetch"
                         andParameters:@{
                                 @"classification" : classificationParameter
                         }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        NSDictionary *results = getTask.result;

        NSError *error;
        [self validateServerResponse:results error:&error];
        if (error) {
            callback(nil, error);
        } else {
            NSArray *categories = results[@"categories"];
            if (callback) {
                __block NSUInteger order = 0;

                NSMutableArray *imojiCategories = [NSMutableArray arrayWithCapacity:categories.count];

                for (NSDictionary *dictionary in categories) {
                    [imojiCategories addObject:[IMMutableCategoryObject objectWithIdentifier:[dictionary im_checkedStringForKey:@"searchText"]
                                                                                       order:order++
                                                                                previewImoji:[self readImojiObject:dictionary]
                                                                                    priority:[dictionary im_checkedNumberForKey:@"priority" defaultValue:@0].unsignedIntegerValue
                                                                                       title:[dictionary im_checkedStringForKey:@"title"]]];
                }

                callback(imojiCategories, nil);
            }
        }

        return nil;
    }];

    return cancellationToken;
}

- (NSOperation *)searchImojisWithTerm:(NSString *)searchTerm
                               offset:(NSNumber *)offset
                      numberOfResults:(NSNumber *)numberOfResults
            resultSetResponseCallback:(IMImojiSessionResultSetResponseCallback)resultSetResponseCallback
                imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback {
    NSOperation *cancellationToken = self.cancellationTokenOperation;

    if (numberOfResults && numberOfResults.integerValue <= 0) {
        numberOfResults = nil;
    }

    if (offset && offset.integerValue < 0) {
        offset = nil;
    }

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
            @"query" : searchTerm,
            @"numResults" : numberOfResults != nil ? numberOfResults : [NSNull null],
            @"offset" : offset != nil ? offset : @0
    }];

    [[self runValidatedGetTaskWithPath:@"/imoji/search" andParameters:parameters] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        NSDictionary *results = getTask.result;

        NSError *error;
        [self validateServerResponse:results error:&error];
        if (error) {
            resultSetResponseCallback(nil, error);
        } else {
            [self handleImojiFetchResponse:[self convertServerDataSetToImojiArray:results]
                                   quality:IMImojiObjectRenderSizeThumbnail
                         cancellationToken:cancellationToken
                    searchResponseCallback:resultSetResponseCallback
                     imojiResponseCallback:imojiResponseCallback];
        }

        return nil;
    }];

    return cancellationToken;
}

- (NSOperation *)getFeaturedImojisWithNumberOfResults:(NSNumber *)numberOfResults
                            resultSetResponseCallback:(IMImojiSessionResultSetResponseCallback)resultSetResponseCallback
                                imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback {
    NSOperation *cancellationToken = self.cancellationTokenOperation;

    id numResultsValue;
    if (numberOfResults && numberOfResults.integerValue <= 0) {
        numResultsValue = [NSNull null];
    } else {
        numResultsValue = numberOfResults != nil ? numberOfResults : [NSNull null];
    }

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
            @"numResults" : numResultsValue
    }];

    [[self runValidatedGetTaskWithPath:@"/imoji/featured/fetch" andParameters:parameters] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        if (cancellationToken.cancelled) {
            return [BFTask cancelledTask];
        }

        if (getTask.error) {
            resultSetResponseCallback(nil, getTask.error);
            return nil;
        }

        NSDictionary *results = getTask.result;
        NSError *error;
        [self validateServerResponse:results error:&error];

        if (error) {
            resultSetResponseCallback(nil, error);
        } else {
            [self handleImojiFetchResponse:[self convertServerDataSetToImojiArray:results]
                                   quality:IMImojiObjectRenderSizeThumbnail
                         cancellationToken:cancellationToken
                    searchResponseCallback:resultSetResponseCallback
                     imojiResponseCallback:imojiResponseCallback];
        }

        return nil;
    }];

    return cancellationToken;
}

- (NSOperation *)fetchImojisByIdentifiers:(NSArray *)imojiObjectIdentifiers
                  fetchedResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)fetchedResponseCallback {
    NSOperation *cancellationToken = self.cancellationTokenOperation;
    if (!imojiObjectIdentifiers || imojiObjectIdentifiers.count == 0) {
        fetchedResponseCallback(nil, NSUIntegerMax, [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                                        code:IMImojiSessionErrorCodeInvalidArgument
                                                                    userInfo:@{
                                                                            NSLocalizedDescriptionKey : @"imojiObjectIdentifiers is either nil or empty"
                                                                    }]);
        return cancellationToken;
    }
    BOOL validArray = YES;
    for (id objectIdentifier in imojiObjectIdentifiers) {
        if (!objectIdentifier || ![objectIdentifier isKindOfClass:[NSString class]]) {
            validArray = NO;
            break;
        }
    }

    if (!validArray) {
        fetchedResponseCallback(nil, NSUIntegerMax, [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                                        code:IMImojiSessionErrorCodeInvalidArgument
                                                                    userInfo:@{
                                                                            NSLocalizedDescriptionKey : @"imojiObjectIdentifiers must contain NSString objects only"
                                                                    }]);
        return cancellationToken;
    }

    NSMutableArray *localImojis = [NSMutableArray new];
    NSMutableArray *remoteImojis = [NSMutableArray new];
    for (NSString *objectIdentifier in imojiObjectIdentifiers) {
        IMMutableImojiObject *imojiObject = [IMMutableImojiObject imojiWithIdentifier:objectIdentifier
                                                                                 tags:@[] // todo: persist tags
                                                                         thumbnailURL:nil
                                                                              fullURL:nil
                                                                               format:IMImojiPreferredImageFormat];

        IMMutableImojiSessionStoragePolicy *policy = (IMMutableImojiSessionStoragePolicy *) self.storagePolicy;
        if ([policy imojiExists:imojiObject quality:IMImojiObjectRenderSizeThumbnail format:IMImojiPreferredImageFormat] &&
                [policy imojiExists:imojiObject quality:IMImojiObjectRenderSizeFullResolution format:IMImojiPreferredImageFormat]) {
            [localImojis addObject:imojiObject];
        } else {
            [remoteImojis addObject:objectIdentifier];
        }
    }

    if (remoteImojis.im_isEmpty) {
        NSUInteger index = 0;
        for (IMImojiObject *imoji in localImojis) {
            fetchedResponseCallback(imoji, index, nil);
            ++index;
        }
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
                @"ids" : [remoteImojis componentsJoinedByString:@","]
        }];

        [[self runValidatedPostTaskWithPath:@"/imoji/fetchMultiple" andParameters:parameters] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
            if (cancellationToken.cancelled) {
                return [BFTask cancelledTask];
            }

            NSDictionary *results = getTask.result;
            NSError *error;
            [self validateServerResponse:results error:&error];

            if (error) {
                fetchedResponseCallback(nil, NSUIntegerMax, error);
            } else {
                NSMutableArray *imojiObjects = [NSMutableArray arrayWithArray:[self convertServerDataSetToImojiArray:results]];
                [imojiObjects addObjectsFromArray:localImojis];

                [self handleImojiFetchResponse:imojiObjects
                                       quality:IMImojiObjectRenderSizeThumbnail
                             cancellationToken:cancellationToken
                        searchResponseCallback:nil
                         imojiResponseCallback:fetchedResponseCallback];
            }

            return nil;
        }];
    }
    return cancellationToken;
}

- (void)clearUserSynchronizationStatus:(IMImojiSessionAsyncResponseCallback)callback {
    [self renewCredentials:callback];
}

#pragma mark Rendering

- (NSOperation *)renderImoji:(IMImojiObject *)imoji
                     options:(IMImojiObjectRenderingOptions *)options
                    callback:(IMImojiSessionImojiRenderResponseCallback)callback {
    NSOperation *cancellationToken = self.cancellationTokenOperation;

    if (!imoji || ![imoji isKindOfClass:[IMImojiObject class]] || !imoji.identifier) {
        NSError *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                             code:IMImojiSessionErrorCodeImojiDoesNotExist
                                         userInfo:@{
                                                 NSLocalizedDescriptionKey : @"Imoji is invalid"
                                         }];

        callback(nil, error);

        return cancellationToken;
    } else if (![imoji isKindOfClass:[IMMutableImojiObject class]]) {
        [self fetchImojisByIdentifiers:@[imoji.identifier]
               fetchedResponseCallback:^(IMImojiObject *internalImoji, NSUInteger index, NSError *error) {
                   if (cancellationToken.cancelled) {
                       return;
                   }

                   [self renderImoji:(IMMutableImojiObject *) internalImoji
                             options:options callback:callback
                   cancellationToken:cancellationToken];
               }];
    } else {
        [self renderImoji:(IMMutableImojiObject *) imoji
                  options:options callback:callback
        cancellationToken:cancellationToken];
    }

    return cancellationToken;
}

- (void)renderImoji:(IMMutableImojiObject *)imoji
            options:(IMImojiObjectRenderingOptions *)options
           callback:(IMImojiSessionImojiRenderResponseCallback)callback
  cancellationToken:(NSOperation *)cancellationToken {

    [[self downloadImojiContents:imoji quality:options.renderSize cancellationToken:cancellationToken] continueWithBlock:^id(BFTask *task) {
        if (cancellationToken.cancelled) {
            return [BFTask cancelledTask];
        }

        if (task.error) {
            callback(nil, task.error);
        } else {
            [BFTask im_serialBackgroundTaskWithBlock:^id(BFTask *bgTask) {
                NSError *error;
                UIImage *image = [self renderImoji:imoji
                                           options:options
                                             error:&error];

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!cancellationToken.cancelled) {
                        callback(image, error);
                    }
                });

                return nil;
            }];
        }

        return nil;
    }];
}

- (UIImage *)renderImoji:(IMMutableImojiObject *)imoji
                 options:(IMImojiObjectRenderingOptions *)options
                   error:(NSError **)error {

    CGSize targetSize = options.targetSize ? options.targetSize.CGSizeValue : CGSizeZero;
    CGSize aspectRatio = options.aspectRatio ? options.aspectRatio.CGSizeValue : CGSizeZero;
    CGSize maximumRenderSize = options.maximumRenderSize ? options.maximumRenderSize.CGSizeValue : CGSizeZero;
    NSString *cacheKey = self.contentCache ? [NSString stringWithFormat:@"%@_%lu", imoji.identifier, (unsigned long) options.hash] : nil;

    if (cacheKey) {
        UIImage *cachedContent = [self.contentCache objectForKey:cacheKey];
        if (cachedContent) {
            return cachedContent;
        }
    }

    NSData *imojiData = [(IMMutableImojiSessionStoragePolicy *) self.storagePolicy readImojiImage:imoji quality:options.renderSize format:imoji.imageFormat];
    if (imojiData) {
        UIImage *image = [UIImage imageWithData:imojiData];

        if (image.size.width == 0 || image.size.height == 0) {
            if (error) {
                *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                             code:IMImojiSessionErrorCodeInvalidImage
                                         userInfo:@{
                                                 NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Invalid image for imoji %@", imoji.identifier]
                                         }];
            }
            return nil;
        }

        if (targetSize.width <= 0 || targetSize.height <= 0) {
            targetSize = image.size;
        }

        // size the image appropriately for aspect enabled outputs, this allows the caller to specify a maximum
        // rendered image size with aspect
        if (!CGSizeEqualToSize(CGSizeZero, aspectRatio) && !CGSizeEqualToSize(CGSizeZero, maximumRenderSize)) {
            // get the potential size of the image with aspect
            CGSize targetSizeWithAspect = [image im_imageSizeWithAspect:aspectRatio];

            // scale down the size to whatever the caller specified
            if (targetSizeWithAspect.width > maximumRenderSize.width) {
                targetSizeWithAspect = CGSizeMake(maximumRenderSize.width, targetSizeWithAspect.height * maximumRenderSize.width / targetSizeWithAspect.width);
            } else if (maximumRenderSize.height > 0.0f && targetSizeWithAspect.height > maximumRenderSize.height) {
                targetSizeWithAspect = CGSizeMake(targetSizeWithAspect.width * maximumRenderSize.height / targetSizeWithAspect.height, maximumRenderSize.height);
            }

            // snap to either the max width or height of the aspect region and reset the shadow/border values appropriately
            if (image.size.width > targetSizeWithAspect.width) {
                targetSize = CGSizeMake(targetSizeWithAspect.width, targetSizeWithAspect.width);
            } else if (image.size.height > targetSizeWithAspect.height) {
                targetSize = CGSizeMake(targetSizeWithAspect.height, targetSizeWithAspect.height);
            }
        }

        UIImage *resizedImage = CGSizeEqualToSize(targetSize, CGSizeZero) ? image : [image im_resizedImageToFitInSize:targetSize scaleIfSmaller:YES];

        if (!CGSizeEqualToSize(CGSizeZero, aspectRatio)) {
            resizedImage = [resizedImage im_imageWithAspect:aspectRatio];
        }

        resizedImage = [resizedImage im_imageWithScreenScale];

        if (self.contentCache && cacheKey) {
            [self.contentCache setObject:resizedImage forKey:cacheKey];
        }

        return resizedImage;
    } else {
        if (error) {
            *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                         code:IMImojiSessionErrorCodeImojiDoesNotExist
                                     userInfo:@{
                                             NSLocalizedDescriptionKey : [NSString stringWithFormat:@"imoji %@ does not exist", imoji.identifier]
                                     }];
        }
    }

    return nil;
}

#pragma mark Static

+ (NSDictionary *)categoryClassifications {
    static NSDictionary *categoryClassifications = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        categoryClassifications = @{
                @(IMImojiSessionCategoryClassificationTrending) : @"trending",
                @(IMImojiSessionCategoryClassificationGeneric) : @"generic"
        };
    });

    return categoryClassifications;
}

#pragma mark Initializers

+ (instancetype)imojiSession {
    return [[IMImojiSession alloc] init];
}

+ (instancetype)imojiSessionWithStoragePolicy:(IMImojiSessionStoragePolicy *)storagePolicy {
    return [[IMImojiSession alloc] initWithStoragePolicy:storagePolicy];
}

@end
