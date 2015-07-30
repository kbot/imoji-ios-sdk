//
// Created by Nima on 7/30/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import <Bolts/BFTask.h>
#import "IMImojiSession+Testing.h"
#import "IMImojiSession+Private.h"
#import "IMImojiSessionCredentials.h"
#import "NSString+Utils.h"


@implementation IMImojiSession (Testing)

#pragma mark Testing

- (BFTask *)randomAuthToken {
    [IMImojiSession credentials].accessToken = [NSString im_stringWithRandomUUID];
    return [self writeAuthenticationCredentials];
}

@end
