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
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "IMImojiObjectRenderingOptions.h"

@interface IMImojiSession (UserSynchronization)

/**
* @abstract Attempts to synchronize a session with the iOS Imoji application. This method will open the Imoji application
* and either ask the user to register/login if there is no active session, or grant the logged in user access to the
* allow ImojiSDK to access it's information. If the application is not installed or does not support authorization,
* an error is returned in the callback.
* @param error If an error occurred while trying to load the Imoji iOS application
*/
- (void)requestUserSynchronizationWithError:(NSError **)error;

/**
* @abstract Used to determine if the launched URL from application:openURL:sourceApplication:annotation in
* UIApplicationDelegate is originated by the ImojiSDK
* @param url URL from application:openURL:sourceApplication:annotation
* @param sourceApplication If an error occurred while trying to load the Imoji iOS application
* @see [UIApplicationDelegate application:openURL:sourceApplication:annotation:](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/index.html#//apple_ref/occ/intfm/UIApplicationDelegate/application:openURL:sourceApplication:annotation:)
*/
- (BOOL)isImojiAppRequest:(NSURL * __nonnull)url sourceApplication:(NSString * __nonnull)sourceApplication;

/**
* @abstract Handles the URL passed to application:openURL:sourceApplication:annotation for authentication
* @param url URL from UIApplicationDelegate application:openURL:sourceApplication:annotation
* @param sourceApplication sourceApplication from UIApplicationDelegate application:openURL:sourceApplication:annotation
* @see [UIApplicationDelegate application:openURL:sourceApplication:annotation:](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/index.html#//apple_ref/occ/intfm/UIApplicationDelegate/application:openURL:sourceApplication:annotation:)
*/
- (BOOL)handleImojiAppRequest:(NSURL * __nonnull)url sourceApplication:(NSString * __nonnull)sourceApplication;

/**
* @abstract Removes the synchronization state from the session. Upon calling this method
* @param callback Status callback triggered when the routine is finished. This can be nil.
*/
- (void)clearUserSynchronizationStatus:(IMImojiSessionAsyncResponseCallback __nonnull)callback;

@end
