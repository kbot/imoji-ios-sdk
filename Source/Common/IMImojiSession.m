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
#import <Bolts/BFAppLink.h>
#import <Bolts/BFAppLinkNavigation.h>
#import <Bolts/BFAppLinkTarget.h>
#import <Bolts/BFURL.h>
#import "ImojiSDK.h"
#import "UIImage+Formats.h"
#import "NSDictionary+Utils.h"
#import "IMMutableImojiObject.h"
#import "UIImage+Extensions.h"
#import "IMMutableCategoryObject.h"
#import "BFTask+Utils.h"
#import "IMMutableImojiSessionStoragePolicy.h"
#import "ImojiSDKConstants.h"
#import "NSArray+Utils.h"
#import "NSString+Utils.h"
#import "RequestUtils.h"

@interface IMImojiSessionCredentials : NSObject

@property(nonatomic, copy) NSString *accessToken;
@property(nonatomic, copy) NSString *refreshToken;
@property(nonatomic, copy) NSDate *expirationDate;
@property(nonatomic) BOOL accountSynchronized;

@end

@interface IMImojiSession ()

@property(nonatomic, strong) IMMutableImojiSessionStoragePolicy *storagePolicy;

@end

NSString *const IMImojiSessionErrorDomain = @"IMImojiSessionErrorDomain";
NSString *const IMImojiSessionFileAccessTokenKey = @"at";
NSString *const IMImojiSessionFileRefreshTokenKey = @"rt";
NSString *const IMImojiSessionFileExpirationKey = @"ex";
NSString *const IMImojiSessionFileUserSynchronizedKey = @"sy";
NSUInteger const IMImojiSessionNumberOfRetriesForImojiDownload = 3;

@implementation IMImojiSession {

}

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

    self.storagePolicy = (IMMutableImojiSessionStoragePolicy *) storagePolicy;
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
            if ([self.storagePolicy imojiExists:imoji quality:quality]) {
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

- (NSOperation *)getImojiCategories:(IMImojiSessionImojiCategoriesResponseCallback)callback {
    return [self getImojiCategoriesWithClassification:IMImojiSessionCategoryClassificationGeneric
                                             callback:callback];
}

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
                    [imojiCategories addObject:[IMMutableCategoryObject objectWithIdentifier:[dictionary im_checkedStringForKey:@"id"]
                                                                                       order:order++
                                                                                previewImoji:[self readImojiObject:dictionary[@"imoji"]]
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
        DLog(@"Invalid number of results %@, defaulting to nil", numberOfResults);
        numberOfResults = nil;
    }

    if (offset && offset.integerValue < 0) {
        DLog(@"Invalid offset %@, defaulting to nil", numberOfResults);
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
        DLog(@"Invalid number of results %@, defaulting to nil", numberOfResults);
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

- (NSOperation *)getImojisForAuthenticatedUserWithResultSetResponseCallback:(IMImojiSessionResultSetResponseCallback)resultSetResponseCallback
                                                      imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback {
    NSOperation *cancellationToken = self.cancellationTokenOperation;

    if (self.sessionState != IMImojiSessionStateConnectedSynchronized) {
        resultSetResponseCallback(nil, [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                           code:IMImojiSessionErrorCodeSessionNotSynchronized
                                                       userInfo:@{
                                                               NSLocalizedDescriptionKey : @"IMImojiSession has not been synchronized."
                                                       }]);

        return cancellationToken;
    }

    [[self runValidatedGetTaskWithPath:@"/user/imoji/fetch" andParameters:@{}] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        if (cancellationToken.cancelled) {
            return [BFTask cancelledTask];
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
                                                                               format:IMPhotoImageFormatWebP];

        if ([self.storagePolicy imojiExists:imojiObject quality:IMImojiObjectRenderSizeThumbnail] &&
                [self.storagePolicy imojiExists:imojiObject quality:IMImojiObjectRenderSizeFullResolution]) {
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

- (NSOperation *)addImojiToUserCollection:(IMImojiObject *)imojiObject
                                 callback:(IMImojiSessionAsyncResponseCallback)callback {
    NSOperation *cancellationToken = self.cancellationTokenOperation;

    if (self.sessionState != IMImojiSessionStateConnectedSynchronized) {
        callback(NO, [NSError errorWithDomain:IMImojiSessionErrorDomain
                                         code:IMImojiSessionErrorCodeSessionNotSynchronized
                                     userInfo:@{
                                             NSLocalizedDescriptionKey : @"IMImojiSession has not been synchronized."
                                     }]);

        return cancellationToken;
    }

    [[self runValidatedPostTaskWithPath:@"/user/imoji/collection/add" andParameters:@{
            @"imojiId" : imojiObject.identifier
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        if (cancellationToken.cancelled) {
            return [BFTask cancelledTask];
        }

        NSDictionary *results = getTask.result;
        NSError *error;
        [self validateServerResponse:results error:&error];

        if (error) {
            callback(NO, error);
        } else {
            callback(YES, nil);
        }

        return nil;
    }];

    return cancellationToken;
}

- (void)requestUserSynchronizationWithError:(NSError **)error {
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", ImojiSDKAuthURLScheme]]]) {
        if (error) {
            *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                         code:IMImojiSessionErrorCodeImojiApplicationNotInstalled
                                     userInfo:@{
                                             NSLocalizedDescriptionKey : @"Imoji application is not installed"
                                     }];
        }
    }

    [[self getEncryptedClientToken] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            DLog(@"Unable to verify client %@", task.error);
            if (error) {
                *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                             code:IMImojiSessionErrorCodeUserAuthenticationFailed
                                         userInfo:@{
                                                 NSLocalizedDescriptionKey : @"Unable to verify client"
                                         }];
            }

            return nil;
        }

        BFAppLinkTarget *target = [BFAppLinkTarget appLinkTargetWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", ImojiSDKAuthURLScheme]]
                                                             appStoreId:ImojiSDKMainAppStoreId
                                                                appName:ImojiSDKMainAppStoreName];

        BFAppLink *appLink = [BFAppLink appLinkWithSourceURL:[NSURL URLWithString:ImojiSDKAuthWebUrl]
                                                     targets:@[target]
                                                      webURL:nil];

        BFAppLinkNavigation *navigation = [BFAppLinkNavigation navigationWithAppLink:appLink
                                                                              extras:@{
                                                                                      ImojiSDKAuthClientPayloadURLKey : task.result,
                                                                                      ImojiSDKAuthReferringAppSchemeURLKey : self.externalApplicationScheme
                                                                              }
                                                                         appLinkData:@{}];

        NSError *navigationError = nil;
        BFAppLinkNavigationType navigationType = [navigation navigate:&navigationError];

        switch (navigationType) {
            case BFAppLinkNavigationTypeApp:
                break;


            case BFAppLinkNavigationTypeBrowser: {
                if (error) {
                    *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                 code:IMImojiSessionErrorCodeImojiApplicationNotInstalled
                                             userInfo:@{
                                                     NSLocalizedDescriptionKey : @"Imoji application is not installed"
                                             }];
                }

                break;
            };
            case BFAppLinkNavigationTypeFailure:
            default:
                if (navigationError && error) {
                    DLog(@"Unable to open link %@", navigationError);
                    *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                 code:IMImojiSessionErrorCodeUserAuthenticationFailed
                                             userInfo:@{
                                                     NSLocalizedDescriptionKey : @"Unable to open imoji application"
                                             }];
                }

                break;
        }

        return nil;
    }];
}

- (BOOL)isImojiAppRequest:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    BFURL *parsedUrl = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];
    return (parsedUrl && [parsedUrl.inputURL.scheme isEqualToString:self.externalApplicationScheme]);
}

- (BOOL)handleImojiAppRequest:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    BFURL *parsedUrl = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];

    NSNumber *status = parsedUrl.appLinkExtras[ImojiSDKAuthStatus];
    if (status && status.boolValue) {
        [IMImojiSession credentials].accountSynchronized = YES;
        [self writeAuthenticationCredentials];
        [self updateImojiState:IMImojiSessionStateConnectedSynchronized];
    }

    return YES;
}

- (void)clearUserSynchronizationStatus:(IMImojiSessionAsyncResponseCallback)callback {
    [IMImojiSession credentials].accessToken = nil;
    [IMImojiSession credentials].refreshToken = nil;
    [IMImojiSession credentials].expirationDate = nil;
    [IMImojiSession credentials].accountSynchronized = NO;

    [[self validateSession] continueWithBlock:^id(BFTask *task) {
        if (callback) {
            if (task.error) {
                callback(NO, task.error);
            } else {
                callback(YES, nil);
            }
        }

        return nil;
    }];
}

#pragma mark Testing

- (BFTask *)randomAuthToken {
    [IMImojiSession credentials].accessToken = [NSString im_stringWithRandomUUID];
    return [self writeAuthenticationCredentials];
}

#pragma mark Metadata

- (BFTask *)getEncryptedClientToken {
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
            @"clientId" : [[ImojiSDK sharedInstance].clientId.UUIDString lowercaseString]
    }];

    [[self runValidatedPostTaskWithPath:@"/oauth/external/getIdPayload" andParameters:parameters] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        NSDictionary *results = getTask.result;
        NSError *error;
        [self validateServerResponse:results error:&error];

        if (error) {
            taskCompletionSource.error = error;
        } else {
            taskCompletionSource.result = results[@"payload"];
        }

        return nil;
    }];

    return taskCompletionSource.task;
}

- (NSString *)externalApplicationScheme {
    return [NSString stringWithFormat:@"imoji%@", [[ImojiSDK sharedInstance].clientId.UUIDString lowercaseString]];
}

#pragma mark Internal

- (BOOL)validateServerResponse:(NSDictionary *)results error:(NSError **)error {
    NSString *status = [results im_checkedStringForKey:@"status"];
    if (![@"SUCCESS" isEqualToString:status]) {
        if (error) {
            *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                         code:IMImojiSessionErrorCodeServerError
                                     userInfo:@{
                                             NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Imoji Server returned %@", status]
                                     }];
        }

        return NO;
    }

    return YES;
}

- (BFTask *)validateSession {
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    [BFTask im_serialBackgroundTaskWithBlock:^id(BFTask *task) {
        if (![ImojiSDK sharedInstance].clientId) {
            NSError *apiError = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                    code:IMImojiSessionErrorCodeInvalidCredentials
                                                userInfo:@{
                                                        NSLocalizedDescriptionKey : @"clientId not specified. Call [[ImojiSDK sharedInstance] setClientId:apiToken:] before making this call."
                                                }];
            taskCompletionSource.error = apiError;

        } else if (![ImojiSDK sharedInstance].apiToken) {
            NSError *apiError = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                    code:IMImojiSessionErrorCodeInvalidCredentials
                                                userInfo:@{
                                                        NSLocalizedDescriptionKey : @"apiToken not specified. Call [[ImojiSDK sharedInstance] setClientId:apiToken:] before making this call."
                                                }];
            taskCompletionSource.error = apiError;
        }

        if ([IMImojiSession credentials].accessToken) {
            // refresh
            if ([IMImojiSession credentials].expirationDate && [[IMImojiSession credentials].expirationDate compare:[NSDate date]] != NSOrderedDescending) {
                DLog(@"Getting new session with refresh token…");
                [[self runPostTaskWithPath:@"/oauth/token"
                                   headers:self.getOAuthBearerHeaders
                             andParameters:@{@"grant_type" : @"refresh_token", @"refresh_token" : [IMImojiSession credentials].refreshToken}]
                        continueWithBlock:^id(BFTask *postTask) {

                            if ([postTask.result isKindOfClass:[NSDictionary class]]) {
                                NSDictionary *results = postTask.result;

                                [IMImojiSession credentials].accessToken = results[@"access_token"];
                                [IMImojiSession credentials].refreshToken = results[@"refresh_token"];
                                [IMImojiSession credentials].expirationDate = [NSDate dateWithTimeIntervalSinceNow:((NSNumber *) results[@"expires_in"]).integerValue];

                                [self updateImojiState:[IMImojiSession credentials].accountSynchronized ? IMImojiSessionStateConnectedSynchronized : IMImojiSessionStateConnected];
                                taskCompletionSource.result = [IMImojiSession credentials].accessToken;

                            } else {
                                taskCompletionSource.error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                                                 code:IMImojiSessionErrorCodeServerError
                                                                             userInfo:@{
                                                                                     NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Server error: %@", task.result]
                                                                             }];

                                [self updateImojiState:IMImojiSessionStateNotConnected];
                            }

                            return nil;
                        }];
            } else {
                taskCompletionSource.result = [IMImojiSession credentials].accessToken;
                [self updateImojiState:[IMImojiSession credentials].accountSynchronized ? IMImojiSessionStateConnectedSynchronized : IMImojiSessionStateConnected];
            }
        } else {
            DLog(@"Getting new session token…");
            [[self runPostTaskWithPath:@"/oauth/token"
                               headers:self.getOAuthBearerHeaders
                         andParameters:@{@"grant_type" : @"client_credentials"}]
                    continueWithBlock:^id(BFTask *postTask) {

                        if ([postTask.result isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *results = postTask.result;

                            [IMImojiSession credentials].accessToken = results[@"access_token"];
                            [IMImojiSession credentials].refreshToken = results[@"refresh_token"];
                            [IMImojiSession credentials].expirationDate = [NSDate dateWithTimeIntervalSinceNow:((NSNumber *) results[@"expires_in"]).integerValue];
                            [IMImojiSession credentials].accountSynchronized = NO;

                            [self writeAuthenticationCredentials];
                            [self updateImojiState:IMImojiSessionStateConnected];

                            taskCompletionSource.result = [IMImojiSession credentials].accessToken;
                        } else {
                            DLog(@"server error: %@", postTask.error);
                            taskCompletionSource.error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                                             code:IMImojiSessionErrorCodeServerError
                                                                         userInfo:@{
                                                                                 NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Server error: %@", postTask.error]
                                                                         }];

                            [self updateImojiState:IMImojiSessionStateNotConnected];
                        }

                        return nil;
                    }];
        }

        return nil;
    }];

    return taskCompletionSource.task;
}

#pragma mark Authentication Serialization/Deserialization

- (void)readAuthenticationFromDictionary:(NSDictionary *)authenticationInfo {
    [IMImojiSession credentials].accessToken = authenticationInfo[IMImojiSessionFileAccessTokenKey];
    [IMImojiSession credentials].refreshToken = authenticationInfo[IMImojiSessionFileRefreshTokenKey];
    [IMImojiSession credentials].expirationDate = [NSDate dateWithTimeIntervalSince1970:((NSNumber *) authenticationInfo[IMImojiSessionFileExpirationKey]).doubleValue];
    [IMImojiSession credentials].accountSynchronized = authenticationInfo[IMImojiSessionFileUserSynchronizedKey] && ((NSNumber *) authenticationInfo[IMImojiSessionFileUserSynchronizedKey]).boolValue;

    [self updateImojiState:[IMImojiSession credentials].accountSynchronized ? IMImojiSessionStateConnectedSynchronized : IMImojiSessionStateConnected];
}

- (BFTask *)readAuthenticationCredentials {
    return [BFTask im_serialBackgroundTaskWithBlock:^id(BFTask *task) {
        NSString *sessionFile = self.sessionFilePath;
        if ([[NSFileManager defaultManager] fileExistsAtPath:sessionFile]) {
            NSError *error;
            NSData *data = [NSData dataWithContentsOfFile:sessionFile options:0 error:&error];

            if (error) {
                DLog(@"unable to read file %@", error);
            } else {
                NSDictionary *jsonInfo = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:NSJSONReadingAllowFragments
                                                                           error:&error];

                if (error) {
                    DLog(@"unable to read json data %@", error);
                } else {
                    [self readAuthenticationFromDictionary:jsonInfo];
                }
            }

        }

        return nil;
    }];
}

- (BFTask *)writeAuthenticationCredentials {
    NSMutableDictionary *authenticationInfo = [NSMutableDictionary dictionaryWithCapacity:4];

    authenticationInfo[IMImojiSessionFileAccessTokenKey] = [IMImojiSession credentials].accessToken;
    authenticationInfo[IMImojiSessionFileRefreshTokenKey] = [IMImojiSession credentials].refreshToken;
    authenticationInfo[IMImojiSessionFileExpirationKey] = @([IMImojiSession credentials].expirationDate.timeIntervalSince1970);
    authenticationInfo[IMImojiSessionFileUserSynchronizedKey] = @([IMImojiSession credentials].accountSynchronized);

    return [BFTask im_serialBackgroundTaskWithBlock:^id(BFTask *task) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:authenticationInfo
                                                           options:0
                                                             error:&error];

        if (error) {
            DLog(@"unable to serialize link to json %@", error);
            return nil;
        }

        NSString *sessionFile = self.sessionFilePath;
        [jsonData writeToFile:sessionFile options:NSDataWritingAtomic error:&error];

        if (error) {
            DLog(@"unable to write file %@", error);
            return nil;
        }

        NSURL *pathUrl = [NSURL fileURLWithPath:sessionFile];
        [pathUrl setResourceValue:@YES
                           forKey:NSURLIsExcludedFromBackupKey
                            error:&error];

        if (error) {
            DLog(@"unable update file settings %@", error);
            return nil;
        }

        return nil;
    }];
}

#pragma mark Utilities

- (NSOperation *)cancellationTokenOperation {
    return [NSBlockOperation blockOperationWithBlock:^{
    }];
}

- (BFTask *)runPostTaskWithPath:(NSString *)path
                        headers:(NSDictionary *)headers
                  andParameters:(NSDictionary *)parameters {
    return [self runImojiURLRequest:[NSMutableURLRequest POSTRequestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ImojiSDKServerURL, path]]
                                                                 parameters:parameters]
                            headers:headers];
}

- (BFTask *)runValidatedGetTaskWithPath:(NSString *)path
                          andParameters:(NSDictionary *)parameters {
    return [self runValidatedImojiURLRequest:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ImojiSDKServerURL, path]]
                                  parameters:parameters
                                      method:@"GET"
                                     headers:@{}];
}

- (BFTask *)runValidatedPostTaskWithPath:(NSString *)path
                           andParameters:(NSDictionary *)parameters {
    return [self runValidatedImojiURLRequest:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ImojiSDKServerURL, path]]
                                  parameters:parameters
                                      method:@"POST"
                                     headers:@{}];
}

- (NSDictionary *)getRequestHeaders:(NSDictionary *)additionalHeaders {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];

    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSRange startRange = [locale rangeOfString:@"_"];
    NSString *language = [locale stringByReplacingCharactersInRange:NSMakeRange(0, startRange.length + 1)
                                                         withString:[NSLocale preferredLanguages][0]];

    headers[@"Imoji-SDK-Version"] = [ImojiSDK sharedInstance].sdkVersion;

    if (language != nil) {
        headers[@"User-Locale"] = language;
    }

    if (additionalHeaders) {
        [headers addEntriesFromDictionary:additionalHeaders];
    }

    return headers;
}

- (BFTask *)runValidatedImojiURLRequest:(NSURL *)url
                             parameters:(NSDictionary *)parameters
                                 method:(NSString *)method
                                headers:(NSDictionary *)headers {
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    [[self validateSession] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            taskCompletionSource.error = task.error;
        } else {
            NSMutableURLRequest *request;
            NSMutableDictionary *parametersWithAuth = [NSMutableDictionary dictionaryWithDictionary:parameters];
            parametersWithAuth[@"access_token"] = task.result;

            if ([@"GET" isEqualToString:method]) {
                request = [NSMutableURLRequest GETRequestWithURL:url parameters:parametersWithAuth];
            } else if ([@"DELETE" isEqualToString:method]) {
                request = [NSMutableURLRequest DELETERequestWithURL:url parameters:parametersWithAuth];
            } else if ([@"POST" isEqualToString:method]) {
                request = [NSMutableURLRequest POSTRequestWithURL:url parameters:parametersWithAuth];
            } else if ([@"PUT" isEqualToString:method]) {
                request = [NSMutableURLRequest PUTRequestWithURL:url parameters:parametersWithAuth];
            }

            [[self runImojiURLRequest:request headers:headers] continueWithBlock:^id(BFTask *imojiRequest) {
                if (imojiRequest.error) {
                    if (imojiRequest.error.userInfo && [@"invalid_token" isEqualToString:imojiRequest.error.userInfo[@"status"]]) {
                        [self clearUserSynchronizationStatus:^(BOOL successful, NSError *error) {
                            [[self runValidatedImojiURLRequest:url
                                                    parameters:parameters
                                                        method:method
                                                       headers:headers] continueWithBlock:^id(BFTask *validationTask) {
                                if (validationTask.error) {
                                    taskCompletionSource.error = validationTask.error;
                                } else {
                                    taskCompletionSource.result = validationTask.result;
                                }

                                return nil;
                            }];
                        }];
                    } else {
                        taskCompletionSource.error = imojiRequest.error;
                    }
                } else {
                    taskCompletionSource.result = imojiRequest.result;
                }

                return nil;
            }];
        }

        return nil;
    }];

    return taskCompletionSource.task;
}

- (BFTask *)runImojiURLRequest:(NSMutableURLRequest *)request
                       headers:(NSDictionary *)headers {

    [request setAllHTTPHeaderFields:[self getRequestHeaders:headers]];

    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    [[[IMImojiSession ephemeralBackgroundURLSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            taskCompletionSource.error = error;
        } else {
            NSError *jsonError;
            NSDictionary *jsonInfo;

            if (data.length > 0) {
                jsonInfo = [NSJSONSerialization JSONObjectWithData:data
                                                           options:NSJSONReadingAllowFragments
                                                             error:&jsonError];
            } else {
                jsonInfo = nil;
            }

            if (jsonError) {
                DLog(@"unable to read json data %@", error);
                taskCompletionSource.error = jsonError;
            } else {
                if ([response isKindOfClass:[NSHTTPURLResponse class]] &&
                        ((NSHTTPURLResponse *) response).statusCode != 200) {
                    taskCompletionSource.error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                                     code:IMImojiSessionErrorCodeServerError
                                                                 userInfo:jsonInfo];
                } else {
                    taskCompletionSource.result = jsonInfo;
                }
            }
        }
    }] resume];

    return taskCompletionSource.task;
}

- (BFTask *)runExternalURLRequest:(NSMutableURLRequest *)request
                          headers:(NSDictionary *)headers {

    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    [[[IMImojiSession ephemeralBackgroundURLSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            taskCompletionSource.error = error;
        } else {
            taskCompletionSource.result = data;
        }
    }] resume];

    return taskCompletionSource.task;
}


- (NSDictionary *)getOAuthBearerHeaders {
    NSData *stringCredentials = [[NSString stringWithFormat:@"%@:%@", [[ImojiSDK sharedInstance].clientId.UUIDString lowercaseString], [ImojiSDK sharedInstance].apiToken] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Credentials = [stringCredentials base64EncodedStringWithOptions:0];

    return @{
            @"Authorization" : [NSString stringWithFormat:@"Basic %@", base64Credentials]
    };
}

- (NSArray *)convertServerDataSetToImojiArray:(NSDictionary *)serverResponse {
    NSArray *results = serverResponse[@"results"];
    if (!results.im_isEmpty) {
        NSMutableArray *imojiObjectsArray = [NSMutableArray arrayWithCapacity:results.count];
        for (NSDictionary *result in results) {
            [imojiObjectsArray addObject:[self readImojiObject:result]];
        }

        return imojiObjectsArray;
    }

    return @[];
}

- (void)handleImojiFetchResponse:(NSArray *)imojiObjects
                         quality:(IMImojiObjectRenderSize)quality
               cancellationToken:(NSOperation *)cancellationToken
          searchResponseCallback:(IMImojiSessionResultSetResponseCallback)searchResponseCallback
           imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback {
    if (cancellationToken.isCancelled) {
        return;
    }

    if (searchResponseCallback) {
        searchResponseCallback(@(imojiObjects.count), nil);
    }

    for (IMMutableImojiObject *imoji in imojiObjects) {
        if (![self.storagePolicy imojiExists:imoji quality:quality]) {
            [self downloadImojiImageAsync:imoji
                                  quality:quality
                               imojiIndex:[imojiObjects indexOfObject:imoji]
                        cancellationToken:cancellationToken
                    imojiResponseCallback:imojiResponseCallback];
        } else {
            if (imojiResponseCallback && !cancellationToken.isCancelled) {
                imojiResponseCallback(imoji, [imojiObjects indexOfObject:imoji], nil);
            }
        }
    }
}

- (void)downloadImojiImageAsync:(IMMutableImojiObject *)imoji
                        quality:(IMImojiObjectRenderSize)quality
                     imojiIndex:(NSUInteger)imojiIndex
              cancellationToken:(NSOperation *)cancellationToken
          imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback {
    [self downloadImojiImageAsync:imoji
                          quality:quality
                      retriesLeft:IMImojiSessionNumberOfRetriesForImojiDownload
                       imojiIndex:imojiIndex
                cancellationToken:cancellationToken
            imojiResponseCallback:imojiResponseCallback];
}

- (void)downloadImojiImageAsync:(IMMutableImojiObject *)imoji
                        quality:(IMImojiObjectRenderSize)quality
                    retriesLeft:(NSUInteger)retriesLeft
                     imojiIndex:(NSUInteger)imojiIndex
              cancellationToken:(NSOperation *)cancellationToken
          imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback {
    NSURL *url;
    switch (quality) {
        case IMImojiObjectRenderSizeFullResolution:
            url = imoji.fullURL;
            break;

        case IMImojiObjectRenderSizeThumbnail:
            url = imoji.thumbnailURL;
            break;
    }

    [BFTask im_concurrentBackgroundTaskWithBlock:^id(BFTask *task) {
        if (cancellationToken.isCancelled) {
            return [BFTask cancelledTask];
        }

        [[self runExternalURLRequest:[NSMutableURLRequest GETRequestWithURL:url
                                                                 parameters:@{}]
                             headers:@{}] continueWithBlock:^id(BFTask *urlTask) {

            if (urlTask.error) {
                if (!cancellationToken.isCancelled) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (retriesLeft > 0) {
                            [self downloadImojiImageAsync:imoji
                                                  quality:quality
                                              retriesLeft:retriesLeft - 1
                                               imojiIndex:imojiIndex
                                        cancellationToken:cancellationToken
                                    imojiResponseCallback:imojiResponseCallback
                            ];
                        } else {
                            DLog(@"Unable to download %@ error code: %@", url, @(urlTask.error.code));
                            imojiResponseCallback(imoji, imojiIndex, [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                                                         code:IMImojiSessionErrorCodeServerError
                                                                                     userInfo:@{
                                                                                             NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Unable to download %@ error code: %@", url, @(urlTask.error.code)]
                                                                                     }]);
                        }
                    });
                }
            } else {
                UIImage *image = [UIImage im_imageWithData:urlTask.result format:imoji.imageFormat];
                [[self.storagePolicy writeImoji:imoji
                                        quality:quality
                                  imageContents:UIImagePNGRepresentation(image)
                                    synchronous:YES]
                        continueWithExecutor:[BFExecutor mainThreadExecutor]
                                   withBlock:^id(BFTask *writeTask) {
                                       if (!cancellationToken.isCancelled) {
                                           imojiResponseCallback(imoji, imojiIndex, nil);
                                       }

                                       return nil;
                                   }];
            }


            return nil;
        }];

        return nil;
    }];
}

- (IMMutableImojiObject *)readImojiObject:(NSDictionary *)result {
    if (result) {
        NSString *imojiId = result[@"id"];
        NSDictionary * webpImages = result[@"images"][@"webp"];
        NSArray *tags = [result[@"tags"] isKindOfClass:[NSArray class]] ? result[@"tags"] : @[];
        IMPhotoImageFormat format = IMPhotoImageFormatWebP;
        NSURL *thumbURL = [NSURL URLWithString:webpImages[@"150"][@"url"]];
        NSURL *fullURL = [NSURL URLWithString:webpImages[@"1200"][@"url"]];

        return [IMMutableImojiObject imojiWithIdentifier:imojiId
                                                    tags:tags
                                            thumbnailURL:thumbURL
                                                 fullURL:fullURL
                                                  format:format];
    } else {
        return nil;
    }
}

- (void)updateImojiState:(IMImojiSessionState)newState {
    IMImojiSessionState oldState = self.sessionState;

    if (newState != oldState) {
        _sessionState = newState;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(imojiSession:stateChanged:fromState:)]) {
                [self.delegate imojiSession:self stateChanged:newState fromState:oldState];
            }
        });
    }
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

- (UIImage *)renderImoji:(IMImojiObject *)imoji
                 options:(IMImojiObjectRenderingOptions *)options
                   error:(NSError **)error {

    CGSize targetSize = options.targetSize ? options.targetSize.CGSizeValue : CGSizeZero;
    CGSize aspectRatio = options.aspectRatio ? options.aspectRatio.CGSizeValue : CGSizeZero;
    CGSize maximumRenderSize = options.maximumRenderSize ? options.maximumRenderSize.CGSizeValue : CGSizeZero;
    NSString *cacheKey = self.contentCache ? [NSString stringWithFormat:@"%@_%lu", imoji.identifier, (unsigned long)options.hash] : nil;

    if (cacheKey) {
        UIImage *cachedContent = [self.contentCache objectForKey:cacheKey];
        if (cachedContent) {
            return cachedContent;
        }
    }

    NSData *imojiData = [self.storagePolicy readImojiImage:imoji quality:options.renderSize];
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

- (NSString *)sessionFilePath {
    return [NSString stringWithFormat:@"%@/imoji.session", self.storagePolicy.persistentPath.path];
}

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

+ (IMImojiSessionCredentials *)credentials {
    static IMImojiSessionCredentials *authInfo = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        authInfo = [IMImojiSessionCredentials new];
    });

    return authInfo;
}

+ (NSURLSession *)ephemeralBackgroundURLSession {
    static NSURLSession *session = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfiguration.HTTPMaximumConnectionsPerHost = 10;
        sessionConfiguration.networkServiceType = NSURLNetworkServiceTypeDefault;
        sessionConfiguration.URLCache = nil;

        session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    });

    return session;
}

#pragma mark Initializers

+ (instancetype)imojiSession {
    return [[IMImojiSession alloc] init];
}

+ (instancetype)imojiSessionWithStoragePolicy:(IMImojiSessionStoragePolicy *)storagePolicy {
    return [[IMImojiSession alloc] initWithStoragePolicy:storagePolicy];
}

@end

@implementation IMImojiSessionCredentials

@end
