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
#import "IMImojiObject.h"
#import "UIImage+Formats.h"

@interface IMMutableImojiObject : IMImojiObject {
@private
    NSString *__nonnull _identifier;
    NSArray *__nonnull _tags;
    NSDictionary *__nonnull _urls;
}

@property(nonatomic, strong, nullable) NSURL *thumbnailURL;
@property(nonatomic, strong, nullable) NSURL *fullURL;
@property(nonatomic) IMPhotoImageFormat imageFormat;

+ (instancetype __nonnull)imojiWithIdentifier:(NSString *__nonnull)identifier
                                         tags:(NSArray *__nonnull)tags
                                 thumbnailURL:(NSURL *__nullable)thumbnailURL
                                      fullURL:(NSURL *__nullable)fullURL
                                      allUrls:(NSDictionary *__nonnull)allUrls
                                       format:(IMPhotoImageFormat)format;

@end
