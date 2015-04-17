//
// Created by Nima on 4/6/15.
// Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
* An ImojiObject is a reference to a sticker within the ImojiSDK. Consumers should not create this object directly,
* rather, they should use IMImojiSession to get them from the server.
*/
@interface IMImojiObject : NSObject

/**
* @abstract A unique identifier for the imoji. This field is never nil.
*/
@property(nonatomic, strong, readonly) NSString *identifier;

/**
* @abstract One or more tags as NSString's. This field is never nil.
*/
@property(nonatomic, strong, readonly) NSArray *tags;

@end
