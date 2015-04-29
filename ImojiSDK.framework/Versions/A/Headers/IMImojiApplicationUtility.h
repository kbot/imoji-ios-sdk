//
// Created by Nima on 4/29/15.
// Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
* @abstract Provides utility methods for installing the Imoji application to synchronize user accounts
*/
@interface IMImojiApplicationUtility : NSObject

/**
* @abstract Presents a StoreKit modal view controller to download the Imoji application.
* @param parent Parent view controller
* @return The presented StoreKit view controller
*/
+ (UIViewController *)presentApplicationDownloadViewController:(UIViewController *)parent;

/**
* @abstract Launches the App Store application landing on the download page for Imoji
*/
+ (void)showApplicationInAppStore;

@end
