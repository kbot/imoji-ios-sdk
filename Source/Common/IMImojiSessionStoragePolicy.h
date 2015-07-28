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

/**
*  @abstract Configuration object used to determine how to store assets.
*/
@interface IMImojiSessionStoragePolicy : NSObject

/**
*  @abstract Generates a storage policy that writes assets to a temporary directory. Contents stored within the
*  temporary directory are removed after one day of non-usage. Additionally, the operating system can remove the
*  contents at varying times.
*/
+ (instancetype)temporaryDiskStoragePolicy;

/**
*  @abstract Generates a storage policy that writes assets to a specified cache path and persistent information to
*  persistentPath. By default, assets stored to cachePath are removed after one day of non-usage.
*  @param cachePath URL path to store temporary files such as such as imoji images
*  @param persistentPath URL path to store persistent information such as authentication information
*/
+ (instancetype)storagePolicyWithCachePath:(NSURL *)cachePath persistentPath:(NSURL *)persistentPath;

@end
