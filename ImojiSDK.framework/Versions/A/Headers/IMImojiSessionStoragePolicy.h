//
// Created by Nima on 4/6/15.
// Copyright (c) 2015 Builds, Inc. All rights reserved.
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
