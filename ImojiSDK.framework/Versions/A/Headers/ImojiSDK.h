//
//  ImojiSDK.h
//  ImojiSDK
//
//  Created by Nima on 4/6/15.
//  Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IMImojiObject.h"
#import "IMImojiCategoryObject.h"
#import "IMImojiSessionStoragePolicy.h"
#import "IMImojiSession.h"

@interface ImojiSDK : NSObject

@property(readonly, nonatomic, copy) NSString *sdkVersion;
@property(readonly, nonatomic, copy) NSString *clientSecret;
@property(readonly, nonatomic, copy) NSString *clientId;

+ (ImojiSDK *)sharedInstance;

- (void)setClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

@end
