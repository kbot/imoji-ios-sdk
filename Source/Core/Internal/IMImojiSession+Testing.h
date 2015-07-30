//
// Created by Nima on 7/30/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMImojiSession.h"

@class BFTask;

@interface IMImojiSession (Testing)

#pragma mark Testing

- (BFTask *)randomAuthToken;

@end
