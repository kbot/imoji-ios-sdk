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
#import "IMImojiObjectRenderingOptions.h"
#import "IMImojiSessionStoragePolicy.h"
#import "IMImojiSession.h"
#import "IMImojiApplicationUtility.h"

/**
* @abstract Base class for coordinating with other ImojiSDK classes
*/
@interface ImojiSDK : NSObject

/**
* @abstract The version of the SDK
*/
@property(readonly, nonatomic, copy) NSString *sdkVersion;

/**
* @abstract The clientId set within setClientId:apiToken:
*/
@property(readonly, nonatomic, copy) NSUUID *clientId;

/**
* @abstract The apiToken set within setClientId:apiToken:
*/
@property(readonly, nonatomic, copy) NSString *apiToken;

/**
* @abstract Singleton reference of the ImojiSDK object
*/
+ (ImojiSDK *)sharedInstance;

/**
* @abstract Sets the client identifier and api token. This should be called upon loading your application, typically
* in application:didFinishLaunchingWithOptions: in UIApplicationDelegate
* @param clientId The Client ID provided for you application
* @param apiToken The API token provided for you application
*/
- (void)setClientId:(NSUUID *)clientId
           apiToken:(NSString *)apiToken;

@end
