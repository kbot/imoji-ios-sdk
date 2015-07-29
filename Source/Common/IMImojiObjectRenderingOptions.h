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
* DEPRECATED: Border and shadow properties are no longer supported by the ImojiSDK
*/
@property(nonatomic, strong) UIColor *borderColor __deprecated;

/**
* @abstract Percentage of either the width or height (whichever is larger) to use as border width.
* DEPRECATED: Border and shadow properties are no longer supported by the ImojiSDK
*  If nil, a default value of 5% is used
*/
@property(nonatomic, strong) NSNumber *borderWidthPercentage __deprecated;

/**
* @abstract Color of the drop shadow. If nil, an 80% opaque black color is used.
* DEPRECATED: Border and shadow properties are no longer supported by the ImojiSDK
*/
@property(nonatomic, strong) UIColor *shadowColor __deprecated;

/**
* @abstract Percentage of either the width or height (whichever is larger) of the IMImojiObject image to use as shadow blur.
* DEPRECATED: Border and shadow properties are no longer supported by the ImojiSDK
*  If nil, a default value of 3% is used
*/
@property(nonatomic, strong) NSNumber *shadowBlurPercentage __deprecated;

/**
* @abstract An optional aspect ratio to fit the image into when rendering. The height or width is padded appropriately to
* accommodate to the desired aspect
* The content of the NSValue object is a CGSize struct
* @see [NSValue valueWithCGSize:](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSValue_Class/index.html#//apple_ref/occ/clm/NSValue/valueWithCGSize:)
*/
@property(nonatomic, strong) NSValue *aspectRatio;

/**
* @abstract The desired shadow offset in percentages between 0 and 1
* DEPRECATED: Border and shadow properties are no longer supported by the ImojiSDK
* The content of the NSValue object is a CGPoint struct
* @see [NSValue valueWithCGPoint:](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSValue_Class/index.html#//apple_ref/occ/clm/NSValue/valueWithCGPoint:)
*/
@property(nonatomic, strong) NSValue *shadowOffset __deprecated;


+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize;

+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                          borderColor:(UIColor *)borderColor __deprecated;

+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                          borderColor:(UIColor *)borderColor
                borderWidthPercentage:(NSNumber *)borderWidthPercentage __deprecated;

+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                          borderColor:(UIColor *)borderColor
                borderWidthPercentage:(NSNumber *)borderWidthPercentage
                          shadowColor:(UIColor *)shadowColor
                 shadowBlurPercentage:(NSNumber *)shadowBlurPercentage __deprecated;

/**
* @abstract Helper initializer to render images with no border or shadow
* DEPRECATED: Border and shadow properties are no longer supported by the ImojiSDK
* @param renderSize The desired render size
*/
+ (instancetype)borderAndShadowlessOptionsWithRenderSize:(IMImojiObjectRenderSize)renderSize __deprecated;

/**
* @abstract Helper initializer to render images with a shadow but no border
* DEPRECATED: Border and shadow properties are no longer supported by the ImojiSDK
* @param renderSize The desired render size
*/
+ (instancetype)borderlessOptionsWithRenderSize:(IMImojiObjectRenderSize)renderSize __deprecated;

/**
* @abstract Helper initializer to render images with a default border but no shadow
* DEPRECATED: Border and shadow properties are no longer supported by the ImojiSDK
* @param renderSize The desired render size
*/
+ (instancetype)shadowlessOptionsWithRenderSize:(IMImojiObjectRenderSize)renderSize __deprecated;

@end
