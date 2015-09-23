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

#import <UIKit/UIKit.h>

#import "IMImojiObject.h"
#import "IMImojiCategoryObject.h"
#import "IMImojiObjectRenderingOptions.h"
#import "IMImojiSessionStoragePolicy.h"
#import "IMImojiSession.h"

/**
* @abstract Base class for coordinating with other ImojiSDK classes
*/
@interface ImojiSDK : NSObject

/**
* @abstract The version of the SDK
*/
@property(readonly, nonatomic, copy, nonnull) NSString *sdkVersion;

/**
* @abstract The clientId set within setClientId:apiToken:
*/
@property(readonly, nonatomic, copy, nonnull) NSUUID *clientId;

/**
* @abstract The apiToken set within setClientId:apiToken:
*/
@property(readonly, nonatomic, copy, nonnull) NSString *apiToken;

/**
* @abstract Singleton reference of the ImojiSDK object
*/
+ (nonnull ImojiSDK *)sharedInstance;

/**
* @abstract Sets the client identifier and api token. This should be called upon loading your application, typically
* in application:didFinishLaunchingWithOptions: in UIApplicationDelegate
* @param clientId The Client ID provided for you application
* @param apiToken The API token provided for you application
*/
- (void)setClientId:(NSUUID *__nonnull)clientId
           apiToken:(NSString *__nonnull)apiToken;

@end
