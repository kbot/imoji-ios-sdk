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
@property(nonatomic, strong, readonly, nonnull) NSString *identifier;

/**
* @abstract Description of the category. This field is never nil.
*/
@property(nonatomic, strong, readonly, nonnull) NSString * title;

/**
* @abstract An imoji object representing the category. This field is never nil.
*/
@property(nonatomic, strong, readonly, nonnull) IMImojiObject *previewImoji;

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
