//
// Created by Nima on 4/17/15.
// Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

/**
* @abstract Specifies the imoji image quality to use for rendering.
*/
typedef NS_ENUM(NSUInteger, IMImojiObjectRenderSize) {
    /**
    * @abstract When used, a compressed version of the Imoji is downloaded and rendered. This setting is useful when
    * the consumer wishes to load and display multiple imojis as fast as possible. Sizes of the thumbnail imojis vary
    * but do not exceed 150x150 pixels
    */
            IMImojiObjectRenderSizeThumbnail,

    /**
    * @abstract When used, a high resolution image of the Imoji is downloaded and rendered. This setting is useful when
    * the consumer wishes to export the imoji to another application or to simply display a large version of it.
    */
            IMImojiObjectRenderSizeFullResolution
};

/**
* @abstract Defines multiple options for rendering IMImojiObjects to images
*/
@interface IMImojiObjectRenderingOptions : NSObject

/**
* @abstract The desired size of the image to load. For best performance, use IMImojiObjectRenderSizeThumbnail. For
* highest quality, use IMImojiObjectRenderSizeFullResolution
*/
@property(nonatomic) IMImojiObjectRenderSize renderSize;

/**
* @abstract The desired size to scale the IMImojiObject to.
* The content of the NSValue object is a CGSize struct
* @see [NSValue valueWithCGSize:](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSValue_Class/index.html#//apple_ref/occ/clm/NSValue/valueWithCGSize:)
*/
@property(nonatomic, strong) NSValue *targetSize;

/**
* @abstract The maximum bounding size to render the IMImojiObject to. When setting options such as aspectRatio,
* the overall size of the image may grow quite large depending on the aspect. Use this option to limit the growth.
* The content of the NSValue object is a CGSize struct
* @see [NSValue valueWithCGSize:](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSValue_Class/index.html#//apple_ref/occ/clm/NSValue/valueWithCGSize:)
*/
@property(nonatomic, strong) NSValue *maximumRenderSize;

/**
* @abstract Color of the border. If nil, the default border color of white will be used.
*/
@property(nonatomic, strong) UIColor *borderColor;

/**
* @abstract Percentage of either the width or height (whichever is larger) to use as border width.
*  If nil, a default value of 5% is used
*/
@property(nonatomic, strong) NSNumber *borderWidthPercentage;

/**
* @abstract Color of the drop shadow. If nil, an 80% opaque black color is used.
*/
@property(nonatomic, strong) UIColor *shadowColor;

/**
* @abstract Percentage of either the width or height (whichever is larger) of the IMImojiObject image to use as shadow blur.
*  If nil, a default value of 3% is used
*/
@property(nonatomic, strong) NSNumber *shadowBlurPercentage;

/**
* @abstract An optional aspect ratio to fit the image into when rendering. The height or width is padded appropriately to
* accommodate to the desired aspect
* The content of the NSValue object is a CGSize struct
* @see [NSValue valueWithCGSize:](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSValue_Class/index.html#//apple_ref/occ/clm/NSValue/valueWithCGSize:)
*/
@property(nonatomic, strong) NSValue *aspectRatio;

/**
* @abstract The desired shadow offset in percentages between 0 and 1
* The content of the NSValue object is a CGPoint struct
* @see [NSValue valueWithCGPoint:](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSValue_Class/index.html#//apple_ref/occ/clm/NSValue/valueWithCGPoint:)
*/
@property(nonatomic, strong) NSValue *shadowOffset;


+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize;


+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                          borderColor:(UIColor *)borderColor;

+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                          borderColor:(UIColor *)borderColor
                borderWidthPercentage:(NSNumber *)borderWidthPercentage;

+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                          borderColor:(UIColor *)borderColor
                borderWidthPercentage:(NSNumber *)borderWidthPercentage
                          shadowColor:(UIColor *)shadowColor
                 shadowBlurPercentage:(NSNumber *)shadowBlurPercentage;

/**
* @abstract Helper initializer to render images with no border or shadow
* @param renderSize The desired render size
*/
+ (instancetype)borderAndShadowlessOptionsWithRenderSize:(IMImojiObjectRenderSize)renderSize;

/**
* @abstract Helper initializer to render images with a shadow but no border
* @param renderSize The desired render size
*/
+ (instancetype)borderlessOptionsWithRenderSize:(IMImojiObjectRenderSize)renderSize;

/**
* @abstract Helper initializer to render images with a default border but no shadow
* @param renderSize The desired render size
*/
+ (instancetype)shadowlessOptionsWithRenderSize:(IMImojiObjectRenderSize)renderSize;

@end
