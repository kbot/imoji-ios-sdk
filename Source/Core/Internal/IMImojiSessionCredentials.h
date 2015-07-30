//
// Created by Nima on 7/29/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMImojiSessionCredentials : NSObject

@property(nonatomic, copy) NSString *accessToken;
@property(nonatomic, copy) NSString *refreshToken;
@property(nonatomic, copy) NSDate *expirationDate;
@property(nonatomic) BOOL accountSynchronized;

@end
