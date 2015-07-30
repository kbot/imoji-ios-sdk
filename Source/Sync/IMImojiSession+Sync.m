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

#import <Bolts/BFTask.h>
#import <Bolts/BFExecutor.h>
#import <Bolts/BFAppLink.h>
#import <Bolts/BFAppLinkNavigation.h>
#import <Bolts/BFAppLinkTarget.h>
#import <Bolts/BFURL.h>
#import <Bolts/BFTaskCompletionSource.h>
#import "ImojiSDK.h"
#import "ImojiSDKConstants.h"
#import "IMImojiSession+Private.h"

@interface IMImojiSessionCredentials : NSObject

@property(nonatomic, copy) NSString *accessToken;
@property(nonatomic, copy) NSString *refreshToken;
@property(nonatomic, copy) NSDate *expirationDate;
@property(nonatomic) BOOL accountSynchronized;

@end

@implementation IMImojiSession (UserSynchronization)

- (void)requestUserSynchronizationWithError:(NSError **)error {
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", ImojiSDKAuthURLScheme]]]) {
        if (error) {
            *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                         code:IMImojiSessionErrorCodeImojiApplicationNotInstalled
                                     userInfo:@{
                                             NSLocalizedDescriptionKey : @"Imoji application is not installed"
                                     }];
        }
    }

    [[self getEncryptedClientToken] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            if (error) {
                *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                             code:IMImojiSessionErrorCodeUserAuthenticationFailed
                                         userInfo:@{
                                                 NSLocalizedDescriptionKey : @"Unable to verify client"
                                         }];
            }

            return nil;
        }

        BFAppLinkTarget *target = [BFAppLinkTarget appLinkTargetWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://", ImojiSDKAuthURLScheme]]
                                                             appStoreId:ImojiSDKMainAppStoreId
                                                                appName:ImojiSDKMainAppStoreName];

        BFAppLink *appLink = [BFAppLink appLinkWithSourceURL:[NSURL URLWithString:ImojiSDKAuthWebUrl]
                                                     targets:@[target]
                                                      webURL:nil];

        BFAppLinkNavigation *navigation = [BFAppLinkNavigation navigationWithAppLink:appLink
                                                                              extras:@{
                                                                                      ImojiSDKAuthClientPayloadURLKey : task.result,
                                                                                      ImojiSDKAuthReferringAppSchemeURLKey : self.externalApplicationScheme
                                                                              }
                                                                         appLinkData:@{}];

        NSError *navigationError = nil;
        BFAppLinkNavigationType navigationType = [navigation navigate:&navigationError];

        switch (navigationType) {
            case BFAppLinkNavigationTypeApp:
                break;


            case BFAppLinkNavigationTypeBrowser: {
                if (error) {
                    *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                 code:IMImojiSessionErrorCodeImojiApplicationNotInstalled
                                             userInfo:@{
                                                     NSLocalizedDescriptionKey : @"Imoji application is not installed"
                                             }];
                }

                break;
            };
            case BFAppLinkNavigationTypeFailure:
            default:
                if (navigationError && error) {
                    *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                 code:IMImojiSessionErrorCodeUserAuthenticationFailed
                                             userInfo:@{
                                                     NSLocalizedDescriptionKey : @"Unable to open imoji application"
                                             }];
                }

                break;
        }

        return nil;
    }];
}

- (BOOL)isImojiAppRequest:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    BFURL *parsedUrl = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];
    return (parsedUrl && [parsedUrl.inputURL.scheme isEqualToString:self.externalApplicationScheme]);
}

- (BOOL)handleImojiAppRequest:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    BFURL *parsedUrl = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];

    NSNumber *status = parsedUrl.appLinkExtras[ImojiSDKAuthStatus];
    if (status && status.boolValue) {
        [IMImojiSession credentials].accountSynchronized = YES;
        [self writeAuthenticationCredentials];
        [self updateImojiState:IMImojiSessionStateConnectedSynchronized];
    }

    return YES;
}

- (NSString *)externalApplicationScheme {
    return [NSString stringWithFormat:@"imoji%@", [[ImojiSDK sharedInstance].clientId.UUIDString lowercaseString]];
}

- (BFTask *)getEncryptedClientToken {
    BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
            @"clientId" : [[ImojiSDK sharedInstance].clientId.UUIDString lowercaseString]
    }];

    [[self runValidatedPostTaskWithPath:@"/oauth/external/getIdPayload" andParameters:parameters] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        NSDictionary *results = getTask.result;
        NSError *error;
        [self validateServerResponse:results error:&error];

        if (error) {
            taskCompletionSource.error = error;
        } else {
            taskCompletionSource.result = results[@"payload"];
        }

        return nil;
    }];

    return taskCompletionSource.task;
}


@end
