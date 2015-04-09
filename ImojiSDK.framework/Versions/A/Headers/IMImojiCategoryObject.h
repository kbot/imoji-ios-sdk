//
// Created by Nima on 4/6/15.
// Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMImojiObject;

@interface IMImojiCategoryObject : NSObject

@property(nonatomic, strong, readonly) NSString *identifier;
@property(nonatomic, strong, readonly) NSString *title;
@property(nonatomic, strong, readonly) IMImojiObject *previewImoji;
@property(nonatomic, strong, readonly) NSNumber *order;
@property(nonatomic, strong, readonly) NSNumber *priority;

@end
