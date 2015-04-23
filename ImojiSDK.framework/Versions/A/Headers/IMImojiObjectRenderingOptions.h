//
// Created by Nima on 4/17/15.
// Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

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
* The content of the NSValue object is a CGSize struct (use [NSValue valueWithCGSize] to populate)
*/
@property(nonatomic, strong) NSValue *targetSize;

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
* @abstract The desired shadow offset.
* The content of the NSValue object is a CGSize struct (use [NSValue valueWithCGSize] to populate)
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
@end
