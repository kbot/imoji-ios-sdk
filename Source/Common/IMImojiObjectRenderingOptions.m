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

#import "IMImojiObjectRenderingOptions.h"

@implementation IMImojiObjectRenderingOptions {

}

- (instancetype)initWithRenderSize:(IMImojiObjectRenderSize)renderSize
                       borderColor:(UIColor *)borderColor
             borderWidthPercentage:(NSNumber *)borderWidthPercentage
                       shadowColor:(UIColor *)shadowColor
              shadowBlurPercentage:(NSNumber *)shadowBlurPercentage {
    self = [super init];
    if (self) {
        self.renderSize = renderSize;
        self.borderColor = borderColor;
        self.borderWidthPercentage = borderWidthPercentage;
        self.shadowColor = shadowColor;
        self.shadowBlurPercentage = shadowBlurPercentage;
    }

    return self;
}

- (NSUInteger)hash {
    NSUInteger hash = [self.aspectRatio hash];
    hash = hash * 31u + (NSUInteger) self.renderSize;
    hash = hash * 31u + [self.targetSize hash];
    hash = hash * 31u + [self.maximumRenderSize hash];
    hash = hash * 31u + [self.borderColor hash];
    hash = hash * 31u + [self.borderWidthPercentage hash];
    hash = hash * 31u + [self.shadowColor hash];
    hash = hash * 31u + [self.shadowBlurPercentage hash];
    hash = hash * 31u + [self.shadowOffset hash];

    return hash;
}

+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize {
    return [[self alloc] initWithRenderSize:renderSize
                                borderColor:nil
                      borderWidthPercentage:nil
                                shadowColor:nil
                       shadowBlurPercentage:nil];
}

+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                          borderColor:(UIColor *)borderColor {
    return [[self alloc] initWithRenderSize:renderSize
                                borderColor:borderColor
                      borderWidthPercentage:nil
                                shadowColor:nil
                       shadowBlurPercentage:nil];
}

+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                          borderColor:(UIColor *)borderColor
                borderWidthPercentage:(NSNumber *)borderWidthPercentage {
    return [[self alloc] initWithRenderSize:renderSize
                                borderColor:borderColor
                      borderWidthPercentage:borderWidthPercentage
                                shadowColor:nil
                       shadowBlurPercentage:nil];
}

+ (instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                          borderColor:(UIColor *)borderColor
                borderWidthPercentage:(NSNumber *)borderWidthPercentage
                          shadowColor:(UIColor *)shadowColor
                 shadowBlurPercentage:(NSNumber *)shadowBlurPercentage {
    return [[self alloc] initWithRenderSize:renderSize
                                borderColor:borderColor
                      borderWidthPercentage:borderWidthPercentage
                                shadowColor:shadowColor
                       shadowBlurPercentage:shadowBlurPercentage];
}

+ (instancetype)borderAndShadowlessOptionsWithRenderSize:(IMImojiObjectRenderSize)renderSize {
    return [[self alloc] initWithRenderSize:renderSize
                                borderColor:nil
                      borderWidthPercentage:@(0)
                                shadowColor:nil
                       shadowBlurPercentage:@(0)];
}

+ (instancetype)borderlessOptionsWithRenderSize:(IMImojiObjectRenderSize)renderSize {
    return [[self alloc] initWithRenderSize:renderSize
                                borderColor:nil
                      borderWidthPercentage:@(0)
                                shadowColor:nil
                       shadowBlurPercentage:nil];
}

+ (instancetype)shadowlessOptionsWithRenderSize:(IMImojiObjectRenderSize)renderSize {
    return [[self alloc] initWithRenderSize:renderSize
                                borderColor:nil
                      borderWidthPercentage:nil
                                shadowColor:nil
                       shadowBlurPercentage:@(0)];
}

@end
