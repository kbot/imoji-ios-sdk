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

#import <Bolts/BFTask.h>
#import <Bolts/BFExecutor.h>
#import "IMMutableImojiSessionStoragePolicy.h"
#import "BFTask+Utils.h"

NSUInteger const IMMutableImojiSessionStoragePolicyDefaultExpirationTimeInSeconds = 60 * 60 * 24;

@interface IMMutableImojiSessionStoragePolicy () <NSCacheDelegate>
@end

@implementation IMMutableImojiSessionStoragePolicy {

}

- (instancetype)initWithCachePath:(NSURL *)cachePath persistentPath:(NSURL *)persistentPath {
    self = [super init];
    if (self) {
        _cachePath = cachePath;
        _persistentPath = persistentPath;

        [self createDirectoriesIfNeeded];
        [self performCleanupOnOldImages];
    }

    return self;
}

- (void)createDirectoriesIfNeeded {
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.cachePath.path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.cachePath.path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];

        if (error) {
            IMLog(@"Unable to imoji cache directory! %@", error);
        } else {
            IMLog(@"Imoji cache directory is: %@", self.cachePath);
        }
    } else {
        IMLog(@"Imoji cache directory is: %@", self.cachePath);
    }

    if (![[NSFileManager defaultManager] fileExistsAtPath:self.persistentPath.path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:self.persistentPath.path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];

        if (error) {
            IMLog(@"Unable to create image directory! %@", error);
        } else {
            IMLog(@"Persistent Imoji directory is: %@", self.persistentPath.path);
        }
    } else {
        IMLog(@"Persistent Imoji directory is: %@", self.persistentPath.path);
    }

}

- (BFTask *)writeImoji:(IMImojiObject *)imoji
               quality:(IMImojiObjectRenderSize)quality
         imageContents:(NSData *)imageContents
           synchronous:(BOOL)synchronous {
    return [BFTask taskFromExecutor:synchronous ? [BFExecutor mainThreadExecutor] : [BFTask im_concurrentBackgroundExecutor]
                          withBlock:^id(BFTask *task) {
                              NSString *fullImojiPath = [NSString stringWithFormat:@"%@/%@-%@", self.cachePath.path, @(quality), imoji.identifier];
                              NSError *error;

                              [imageContents writeToFile:fullImojiPath options:NSDataWritingAtomic error:&error];

                              NSURL *pathUrl = [NSURL fileURLWithPath:fullImojiPath];
                              [pathUrl setResourceValue:@YES
                                                 forKey:NSURLIsExcludedFromBackupKey
                                                  error:&error];

                              if (error) {
                                  IMLog(@"Unable to write imoji contents for id %@. Reason %@", imoji.identifier, error);
                              }

                              return nil;
                          }];
}

- (NSData *)readImojiImage:(IMImojiObject *)imoji
                   quality:(IMImojiObjectRenderSize)quality {
    NSString *fullImojiPath = [NSString stringWithFormat:@"%@/%@-%@", self.cachePath.path, @(quality), imoji.identifier];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fullImojiPath]) {
        __block NSError *error;
        NSData *data = [NSData dataWithContentsOfFile:fullImojiPath options:0 error:&error];

        [BFTask im_serialBackgroundTaskWithBlock:^id(BFTask *task) {
            [fileManager setAttributes:@{NSFileModificationDate : [NSDate date]}
                          ofItemAtPath:fullImojiPath
                                 error:&error];

            if (error) {
                IMLog(@"unable to update file %@", error);
            }

            return nil;
        }];

        if (error) {
            IMLog(@"unable to read file %@", error);
            return nil;
        } else {
            return data;
        }
    }

    return nil;
}

- (BOOL)imojiExists:(IMImojiObject *)imoji
            quality:(IMImojiObjectRenderSize)quality {
    NSString *fullImojiPath = [NSString stringWithFormat:@"%@/%@-%@", self.cachePath.path, @(quality), imoji.identifier];
    return [[NSFileManager defaultManager] fileExistsAtPath:fullImojiPath];
}

+ (void)removeFile:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];

        if (error) {
            IMLog(@"Unable to remove image directory! %@", error);
        }
    }
}


- (void)performCleanupOnOldImages {
    [BFTask im_concurrentBackgroundTaskWithBlock:^id(BFTask *task) {

        NSDate *now = [NSDate date];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:self.cachePath.path];
        NSError *error;
        for (NSString *imojiImage in enumerator) {
            NSString *path = [NSString stringWithFormat:@"%@/%@", self.cachePath.path, imojiImage];
            NSDictionary *attributes = [manager attributesOfItemAtPath:path error:&error];
            NSDate *modificationDate = attributes[NSFileModificationDate];

            if (modificationDate && [now timeIntervalSinceDate:modificationDate] > IMMutableImojiSessionStoragePolicyDefaultExpirationTimeInSeconds) {
                [IMMutableImojiSessionStoragePolicy removeFile:path];
            }

            if (error) {
                IMLog(@"Unable to get file attributes: %@", error);
            }
        }

        return nil;
    }];
}

@end
