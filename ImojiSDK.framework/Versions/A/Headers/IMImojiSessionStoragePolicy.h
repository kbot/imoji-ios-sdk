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
*  temporary directory are removed at unspecified times by the operating system.
*/
+ (instancetype)temporaryDiskStoragePolicy;

@end
