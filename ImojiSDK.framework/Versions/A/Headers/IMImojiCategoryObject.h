//
// Created by Nima on 4/6/15.
// Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMImojiObject;

extern NSUInteger const IMImojiObjectPriorityFeatured;
extern NSUInteger const IMImojiObjectPriorityDefault;

/**
*  @abstract A category object represents an opaque grouping of imojis.
*/
@interface IMImojiCategoryObject : NSObject

/**
* @abstract A unique id for the category. This field is never nil.
*/
@property(nonatomic, strong, readonly) NSString *identifier;

/**
* @abstract Description of the category. This field is never nil.
*/
@property(nonatomic, strong, readonly) NSString *title;

/**
* @abstract An imoji object representing the category. This field is never nil.
*/
@property(nonatomic, strong, readonly) IMImojiObject *previewImoji;

/**
* @abstract The order of importance to display the category starting from 0
*/
@property(nonatomic, readonly) NSUInteger order;

/**
* @abstract Either IMImojiObjectPriorityFeatured or IMImojiObjectPriorityNormal. Featured categories have
* higher precedence than other categories therefore consuming applications can display them differently to distinguish
* them from the rest of the categories. Typically categories that are trending in the current time frame are high
* priority (ex: current events)
*/
@property(nonatomic, readonly) NSUInteger priority;

@end
