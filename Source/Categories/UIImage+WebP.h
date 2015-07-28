//
//  UIImage+WebP.h
//  iOS-WebP
//
//  Created by Sean Ooi on 12/21/13.
//  Copyright (c) 2013 Sean Ooi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebP/decode.h>
#import <WebP/encode.h>

@interface UIImage (WebP)

+ (UIImage*)im_imageWithWebPData:(NSData*)imgData;

+ (UIImage*)im_imageWithWebP:(NSString*)filePath;

+ (NSData*)im_imageToWebP:(UIImage *)image quality:(CGFloat)quality;

+ (NSData*)im_imageToWebP:(UIImage *)image quality:(CGFloat)quality preset:(WebPPreset)preset;

+ (void)im_imageToWebP:(UIImage *)image
               quality:(CGFloat)quality
                preset:(WebPPreset)preset
       completionBlock:(void (^)(NSData *result))completionBlock
          failureBlock:(void (^)(NSError* error))failureBlock;

+ (void)im_imageToWebP:(UIImage *)image
               quality:(CGFloat)quality
                preset:(WebPPreset)preset
           configBlock:(void (^)(WebPConfig *config))configBlock
       completionBlock:(void (^)(NSData *result))completionBlock
          failureBlock:(void (^)(NSError* error))failureBlock;

+ (void)im_imageWithWebP:(NSString *)filePath
         completionBlock:(void (^)(UIImage *result))completionBlock
            failureBlock:(void (^)(NSError* error))failureBlock;

@end
