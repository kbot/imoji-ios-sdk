//
// Created by Nima on 7/29/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMImojiSession.h"
#import "UIImage+Formats.h"

@class IMImojiSessionCredentials;
@class IMMutableImojiObject;
@class BFTask;

extern IMPhotoImageFormat const IMImojiPreferredImageFormat;

@interface IMImojiSession (Private)

#pragma mark Static

+ (IMImojiSessionCredentials *)credentials;

+ (NSURLSession *)ephemeralBackgroundURLSession;

#pragma mark Auth

- (void)renewCredentials:(IMImojiSessionAsyncResponseCallback)callback;

- (void)readAuthenticationFromDictionary:(NSDictionary *)authenticationInfo;

- (BFTask *)readAuthenticationCredentials;

- (BFTask *)writeAuthenticationCredentials;

- (NSOperation *)cancellationTokenOperation;

#pragma mark Network Requests

- (BFTask *)runPostTaskWithPath:(NSString *)path headers:(NSDictionary *)headers andParameters:(NSDictionary *)parameters;

- (BFTask *)runValidatedGetTaskWithPath:(NSString *)path andParameters:(NSDictionary *)parameters;

- (BFTask *)runValidatedPostTaskWithPath:(NSString *)path andParameters:(NSDictionary *)parameters;

- (BFTask *)validateSession;

#pragma mark Network Responses

- (BOOL)validateServerResponse:(NSDictionary *)results error:(NSError **)error;

- (NSArray *)convertServerDataSetToImojiArray:(NSDictionary *)serverResponse;

- (void)handleImojiFetchResponse:(NSArray *)imojiObjects quality:(IMImojiObjectRenderSize)quality cancellationToken:(NSOperation *)cancellationToken searchResponseCallback:(IMImojiSessionResultSetResponseCallback)searchResponseCallback imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback;

- (void)downloadImojiImageAsync:(IMMutableImojiObject *)imoji quality:(IMImojiObjectRenderSize)quality imojiIndex:(NSUInteger)imojiIndex cancellationToken:(NSOperation *)cancellationToken imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback;

- (IMMutableImojiObject *)readImojiObject:(NSDictionary *)result;

#pragma mark Session State Management

- (void)updateImojiState:(IMImojiSessionState)newState;

@end
