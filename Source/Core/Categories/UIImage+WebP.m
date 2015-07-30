//
//  UIImage+WebP.m
//  iOS-WebP
//
//  Created by Sean Ooi on 12/21/13.
//  Copyright (c) 2013 Sean Ooi. All rights reserved.
//

#import "UIImage+WebP.h"

// Callback for CGDataProviderRelease
static void FreeImageData(void *info, const void *data, size_t size) {
    free((void*)data);
}

@implementation UIImage (WebP)

#pragma mark - Private methods

+ (NSData *)convertToWebP:(UIImage *)image
                  quality:(CGFloat)quality
                   preset:(WebPPreset)preset
              configBlock:(void (^)(WebPConfig *))configBlock
                    error:(NSError **)error
{
    image = [self webPImage:image];

    CGImageRef webPImageRef = image.CGImage;
    size_t webPBytesPerRow = CGImageGetBytesPerRow(webPImageRef);

    size_t webPImageWidth = CGImageGetWidth(webPImageRef);
    size_t webPImageHeight = CGImageGetHeight(webPImageRef);

    CGDataProviderRef webPDataProviderRef = CGImageGetDataProvider(webPImageRef);
    CFDataRef webPImageDatRef = CGDataProviderCopyData(webPDataProviderRef);

    uint8_t *webPImageData = (uint8_t *)CFDataGetBytePtr(webPImageDatRef);

    WebPConfig config;
    if (!WebPConfigPreset(&config, preset, quality)) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Configuration preset failed to initialize." forKey:NSLocalizedDescriptionKey];
        if(error != NULL)
            *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@.errorDomain",  [[NSBundle mainBundle] bundleIdentifier]] code:-101 userInfo:errorDetail];

        CFRelease(webPImageDatRef);
        return nil;
    }

    if (configBlock) {
        configBlock(&config);
    }

    if (!WebPValidateConfig(&config)) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"One or more configuration parameters are beyond their valid ranges." forKey:NSLocalizedDescriptionKey];
        if(error != NULL)
            *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@.errorDomain",  [[NSBundle mainBundle] bundleIdentifier]] code:-101 userInfo:errorDetail];

        CFRelease(webPImageDatRef);
        return nil;
    }

    WebPPicture pic;
    if (!WebPPictureInit(&pic)) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Failed to initialize structure. Version mismatch." forKey:NSLocalizedDescriptionKey];
        if(error != NULL)
            *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@.errorDomain",  [[NSBundle mainBundle] bundleIdentifier]] code:-101 userInfo:errorDetail];

        CFRelease(webPImageDatRef);
        return nil;
    }
    pic.width = (int)webPImageWidth;
    pic.height = (int)webPImageHeight;
    pic.colorspace = WEBP_YUV420;
    pic.use_argb = true;
    WebPPictureImportRGBA(&pic, webPImageData, (int)webPBytesPerRow);
    //WebPPictureARGBToYUVA(&pic, WEBP_YUV420);
    WebPCleanupTransparentArea(&pic);

    WebPMemoryWriter writer;
    WebPMemoryWriterInit(&writer);
    pic.writer = WebPMemoryWrite;
    pic.custom_ptr = &writer;
    WebPEncode(&config, &pic);

    NSData *webPFinalData = [NSData dataWithBytes:writer.mem length:writer.size];

    WebPPictureFree(&pic);
    CFRelease(webPImageDatRef);

    return webPFinalData;
}

+ (UIImage *)imageWithWebP:(NSString *)filePath error:(NSError **)error
{
    // If passed `filepath` is invalid, return nil to caller and log error in console
    NSError *dataError = nil;
    NSData *imgData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&dataError];
    if (dataError != nil) {
        *error = dataError;
        return nil;
    }
    return [UIImage imageWithWebPData:imgData error:error];
}

+ (UIImage *)imageWithWebPData:(NSData *)imgData error:(NSError **)error
{
    WebPDecoderConfig config;
    if (!WebPInitDecoderConfig(&config)) {
        *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@.errorDomain", [[NSBundle mainBundle] bundleIdentifier]] code:-101 userInfo:@{
                NSLocalizedDescriptionKey : @"Unable to initialize webp configuration"
        }];
        return nil;
    }

    config.output.colorspace = MODE_rgbA;
    config.options.use_threads = 1;
    config.options.bypass_filtering = 1;
    config.options.no_fancy_upsampling = 1;

    // Decode the WebP image data into a RGBA value array.
    if (WebPDecode([imgData bytes], [imgData length], &config) != VP8_STATUS_OK) {
        *error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@.errorDomain", [[NSBundle mainBundle] bundleIdentifier]] code:-101 userInfo:@{
                NSLocalizedDescriptionKey : @"Unable to decode webp data"
        }];

        return nil;
    }

    int width = config.input.width;
    int height = config.input.height;

    // Construct a UIImage from the decoded RGBA value array.
    CGDataProviderRef provider =
            CGDataProviderCreateWithData(NULL, config.output.u.RGBA.rgba,
                    config.output.u.RGBA.size, FreeImageData);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef =
            CGImageCreate(width, height, 8, 32, 4 * width, colorSpaceRef, bitmapInfo,
                    provider, NULL, NO, renderingIntent);

    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);

    UIImage *newImage = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);

    return newImage;
}

#pragma mark - Synchronous methods
+ (UIImage *)im_imageWithWebP:(NSString *)filePath
{
    NSError *error;
    NSParameterAssert(filePath != nil);
    UIImage *image = [self imageWithWebP:filePath error:&error];
    
    if (error) {
        NSLog(@"Webp image conversation failed %@", error);
    }
    
    return image;
}

+ (UIImage *)im_imageWithWebPData:(NSData *)imgData
{
    NSError *error;
    NSParameterAssert(imgData != nil);
    UIImage *image = [self imageWithWebPData:imgData error:&error];

    if (error) {
        NSLog(@"Webp image conversation failed %@", error);
    }
    
    return image;
}

+ (NSData *)im_imageToWebP:(UIImage *)image quality:(CGFloat)quality
{
    NSParameterAssert(image != nil);
    NSParameterAssert(quality >= 0.0f && quality <= 100.0f);
    return [self convertToWebP:image quality:quality preset:WEBP_PRESET_DEFAULT configBlock:nil error:nil];
}

+ (NSData*)im_imageToWebP:(UIImage *)image quality:(CGFloat)quality preset:(WebPPreset)preset
{
    NSParameterAssert(image != nil);
    NSParameterAssert(quality >= 0.0f && quality <= 100.0f);
    return [self convertToWebP:image quality:quality preset:preset configBlock:nil error:nil];
}

#pragma mark - Asynchronous methods
+ (void)im_imageWithWebP:(NSString *)filePath completionBlock:(void (^)(UIImage *result))completionBlock failureBlock:(void (^)(NSError *error))failureBlock
{
    NSParameterAssert(filePath != nil);
    NSParameterAssert(completionBlock != nil);
    NSParameterAssert(failureBlock != nil);

    // Create dispatch_queue_t for decoding WebP concurrently
    dispatch_queue_t fromWebPQueue = dispatch_queue_create("com.seanooi.ioswebp.fromwebp", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(fromWebPQueue, ^{

        NSError *error = nil;
        UIImage *webPImage = [self imageWithWebP:filePath error:&error];

        // Return results to caller on main thread in completion block is `webPImage` != nil
        // Else return in failure block
        if(webPImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(webPImage);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        }
    });
}

+ (void)im_imageToWebP:(UIImage *)image
               quality:(CGFloat)quality
                preset:(WebPPreset)preset
       completionBlock:(void (^)(NSData *result))completionBlock
          failureBlock:(void (^)(NSError *error))failureBlock
{
    [self im_imageToWebP:image
                 quality:quality
                  preset:preset
             configBlock:nil
         completionBlock:completionBlock
            failureBlock:failureBlock];
}

+ (void)im_imageToWebP:(UIImage *)image
               quality:(CGFloat)quality
                preset:(WebPPreset)preset
           configBlock:(void (^)(WebPConfig *config))configBlock
       completionBlock:(void (^)(NSData *result))completionBlock
          failureBlock:(void (^)(NSError *error))failureBlock
{
    NSAssert(image != nil, @"imageToWebP:quality:completionBlock:failureBlock image cannot be nil");
    NSAssert(quality >= 0 && quality <= 100, @"imageToWebP:quality:completionBlock:failureBlock quality has to be [0, 100]");
    NSAssert(completionBlock != nil, @"imageToWebP:quality:completionBlock:failureBlock completionBlock cannot be nil");
    NSAssert(failureBlock != nil, @"imageToWebP:quality:completionBlock:failureBlock failureBlock block cannot be nil");

    // Create dispatch_queue_t for encoding WebP concurrently
    dispatch_queue_t toWebPQueue = dispatch_queue_create("com.seanooi.ioswebp.towebp", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(toWebPQueue, ^{

        NSError *error = nil;
        NSData *webPFinalData = [self convertToWebP:image quality:quality preset:preset configBlock:configBlock error:&error];

        // Return results to caller on main thread in completion block is `webPFinalData` != nil
        // Else return in failure block
        if(!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(webPFinalData);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(error);
            });
        }
    });
}

+ (UIImage *)webPImage:(UIImage *)image
{
    // CGImageAlphaInfo of images with alpha are kCGImageAlphaPremultipliedFirst
    // Convert to kCGImageAlphaPremultipliedLast to avoid gray-ish background
    // when encoding alpha images to WebP format

    CGImageRef imageRef = image.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;

    CGContextRef context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);

    UIImage *newImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    return newImage;
}

+ (NSString *)version:(NSInteger)version
{
    // Convert version number to hexadecimal and parse it accordingly
    // E.g: v2.5.7 is 0x020507

    NSString *hex = [NSString stringWithFormat:@"%06lx", (long)version];
    NSMutableArray *array = [NSMutableArray array];
    for (int x = 0; x < [hex length]; x += 2) {
        [array addObject:@([[hex substringWithRange:NSMakeRange(x, 2)] integerValue])];
    }

    return [array componentsJoinedByString:@"."];
}

#pragma mark - Error statuses

+ (NSString *)statusForVP8Code:(VP8StatusCode)code
{
    NSString *errorString;
    switch (code) {
        case VP8_STATUS_OUT_OF_MEMORY:
            errorString = @"OUT_OF_MEMORY";
            break;
        case VP8_STATUS_INVALID_PARAM:
            errorString = @"INVALID_PARAM";
            break;
        case VP8_STATUS_BITSTREAM_ERROR:
            errorString = @"BITSTREAM_ERROR";
            break;
        case VP8_STATUS_UNSUPPORTED_FEATURE:
            errorString = @"UNSUPPORTED_FEATURE";
            break;
        case VP8_STATUS_SUSPENDED:
            errorString = @"SUSPENDED";
            break;
        case VP8_STATUS_USER_ABORT:
            errorString = @"USER_ABORT";
            break;
        case VP8_STATUS_NOT_ENOUGH_DATA:
            errorString = @"NOT_ENOUGH_DATA";
            break;
        default:
            errorString = @"UNEXPECTED_ERROR";
            break;
    }
    return errorString;
}
@end
