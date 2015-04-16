//
// Created by Nima on 4/6/15.
// Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class IMImojiObject, IMImojiSessionStoragePolicy;

extern NSString *IMSDKSessionErrorDomain;

typedef NS_ENUM(NSUInteger, IMImojiSessionErrorCode) {
    IMImojiSessionErrorCodeInvalidCredentials,
    IMImojiSessionErrorCodeServerError,
    IMImojiSessionErrorCodeImojiDoesNotExist,
    IMImojiSessionErrorCodeInvalidArgument,
    IMImojiSessionErrorCodeInvalidImage
};

typedef NS_ENUM(NSUInteger, IMImojiObjectRenderQuality) {
    IMImojiObjectRenderQualityThumbnail,
    IMImojiObjectRenderQualityFullResolution
};

typedef void (^IMImojiSessionSearchResponseCallback)(NSNumber *resultCount, NSError *error);

typedef void (^IMImojiSessionImojiFetchedResponseCallback)(IMImojiObject *imoji, NSUInteger index, NSError *error);

typedef void (^IMImojiSessionImojiCategoriesResponseCallback)(NSArray *imojiCategories, NSError *error);

typedef void (^IMImojiSessionImojiRenderResponseCallback)(UIImage *image, NSError *error);


@interface IMImojiSession : NSObject

/**
* @abstract Creates a imoji session object.
* @param storagePolicy The storage policy to use for persisting imojis.
*/
- (instancetype)initWithStoragePolicy:(IMImojiSessionStoragePolicy *)storagePolicy;

/**
* @abstract Creates a imoji session object with a default temporary file system storage policy.
*/
+ (instancetype)imojiSession;

/**
* @abstract Creates a imoji session object.
* @param storagePolicy The storage policy to use for persisting imojis.
*/
+ (instancetype)imojiSessionWithStoragePolicy:(IMImojiSessionStoragePolicy *)storagePolicy;

@end

@interface IMImojiSession (ImojiFetching)

/**
* @abstract Fetches top level imoji categories.
* @param callback Block callback to call when categories have been downloaded.
* @return An operation reference that can be used to cancel the request.
*/
- (NSOperation *)getImojiCategories:(IMImojiSessionImojiCategoriesResponseCallback)callback;

/**
* @abstract Searches the imojis database with a given search term. The searchResponseCallback block is called once the results are available.
* Imojis contents are downloaded individually and imojiResponseCallback is called once the thumbnail of that imoji has been downloaded.
* @param searchTerm Search term to find imojis with. If nil or empty, the server will typically returned the featured set of imojis (this is subject to change).
* @param offset The result offset from a previous search. This may be nil.
* @param numberOfResults Number of results to fetch. This can be nil.
* @return An operation reference that can be used to cancel the request.
*/
- (NSOperation *)searchImojisWithTerm:(NSString *)searchTerm
                               offset:(NSNumber *)offset
                      numberOfResults:(NSNumber *)numberOfResults
               searchResponseCallback:(IMImojiSessionSearchResponseCallback)searchResponseCallback
                imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback;

/**
* @abstract Gets a random set of featured imojis. The searchResponseCallback block is called once the results are available.
* Imojis contents are downloaded individually and imojiResponseCallback is called once the thumbnail of that imoji has been downloaded.
* @param numberOfResults Number of results to fetch. This can be nil.
* @return An operation reference that can be used to cancel the request.
*/
- (NSOperation *)getFeaturedImojisWithNumberOfResults:(NSNumber *)numberOfResults
                               searchResponseCallback:(IMImojiSessionSearchResponseCallback)searchResponseCallback
                                imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback;

@end


@interface IMImojiSession (ImojiDisplaying)

/**
* @abstract Renders an imoji object into a image with a white border.
* The border widths and shadow size are scaled proportionally to the size of the image.
* @param imoji The imoji to render.
* @param quality The desired quality of the image to load.
* @param callback Called once the imoji UIImage has been rendered
* @return An operation reference that can be used to cancel the request.
*/
- (NSOperation *)renderImoji:(IMImojiObject *)imoji
                     quality:(IMImojiObjectRenderQuality)quality
                    callback:(IMImojiSessionImojiRenderResponseCallback)callback;

/**
* @abstract Renders an imoji object into a image with a white border scaled to fit the specified target size.
* If the target size is larger than the imoji image itself, it will be scaled up to adjust to the size.
* The border widths and shadow size are scaled proportionally to targetSize or the size of the imoji image itself, whichever is smaller
* @param imoji The imoji to render.
* @param quality The desired quality of the image to load.
* @param targetSize The desired size to scale the imoji to. Both the border width and shadow size are scaled proportionally to the target size
* @param callback Called once the imoji UIImage has been rendered
* @return An operation reference that can be used to cancel the request.
*/
- (NSOperation *)renderImoji:(IMImojiObject *)imoji
                     quality:(IMImojiObjectRenderQuality)quality
                  targetSize:(CGSize)targetSize
                    callback:(IMImojiSessionImojiRenderResponseCallback)callback;


/**
* @abstract Renders an imoji object into a image with the specified border color.
* The border widths and shadow size are scaled proportionally to the size of the image.
* @param imoji The imoji to render.
* @param quality The desired quality of the image to load.
* @param borderColor Color of the border.
* @param callback Called once the imoji UIImage has been rendered
* @return An operation reference that can be used to cancel the request.
*/
- (NSOperation *)renderImoji:(IMImojiObject *)imoji
                     quality:(IMImojiObjectRenderQuality)quality
                 borderColor:(UIColor *)borderColor
                    callback:(IMImojiSessionImojiRenderResponseCallback)callback;

/**
* @abstract Renders an imoji object into a image with the specified border color and width.
* @param imoji The imoji to render.
* @param quality The desired quality of the image to load.
* @param borderColor Color of the border.
* @param borderWidth Width of the border.
* @param error Reference to an error object that will be populated if an issue arises upon rendering.
* @return An operation reference that can be used to cancel the request.
*/
- (NSOperation *)renderImoji:(IMImojiObject *)imoji
                     quality:(IMImojiObjectRenderQuality)quality
                 borderColor:(UIColor *)borderColor
                 borderWidth:(CGFloat)borderWidth
                    callback:(IMImojiSessionImojiRenderResponseCallback)callback;

/**
* @abstract Renders an imoji object into a image with a specified border color. The imoji image is scaled to fit the specified target size.
* The border widths and shadow size are scaled proportionally to targetSize or the size of the imoji image itself, whichever is smaller.
* @param imoji The imoji to render.
* @param quality The desired quality of the image to load.
* @param targetSize The desired size to scale the imoji to. Both the border width and shadow size are scaled proportionally to the target size.
* @param borderColor Color of the border.
* @param callback Called once the imoji UIImage has been rendered
* @return An operation reference that can be used to cancel the request.
*/
- (NSOperation *)renderImoji:(IMImojiObject *)imoji
                     quality:(IMImojiObjectRenderQuality)quality
                  targetSize:(CGSize)targetSize
                 borderColor:(UIColor *)borderColor
                    callback:(IMImojiSessionImojiRenderResponseCallback)callback;


/**
* @abstract Renders an imoji object into a image with a specified border color and width. The imoji image is scaled to fit the specified target size.
* @param imoji The imoji to render.
* @param quality The desired quality of the image to load.
* @param targetSize The desired size to scale the imoji to.
* @param borderColor Color of the border.
* @param borderWidth Width of the border.
* @param callback Called once the imoji UIImage has been rendered
* @return An operation reference that can be used to cancel the request.
*/
- (NSOperation *)renderImoji:(IMImojiObject *)imoji
                     quality:(IMImojiObjectRenderQuality)quality
                  targetSize:(CGSize)targetSize
                 borderColor:(UIColor *)borderColor
                 borderWidth:(CGFloat)borderWidth
                    callback:(IMImojiSessionImojiRenderResponseCallback)callback;

@end
