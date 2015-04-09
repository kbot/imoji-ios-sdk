//
// Created by Nima on 4/6/15.
// Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMImojiSessionStoragePolicy : NSObject

@property(nonatomic, strong, readonly) NSURL *localPath;

+ (instancetype)temporaryDiskStoragePolicy;

+ (instancetype)diskStoragePolicyWithPath:(NSURL *)localPath;

@end
