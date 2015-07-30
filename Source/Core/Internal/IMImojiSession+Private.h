//
// Created by Nima on 7/29/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMImojiSession.h"
#import "UIImage+Formats.h"

@class IMImojiSessionCredentials;
@class IMMutableImojiObject;

extern IMPhotoImageFormat const IMImojiPreferredImageFormat;

@interface IMImojiSession (Private)

#pragma mark Static

+ (IMImojiSessionCredentials *)credentials;

+ (NSURLSession *)ephemeralBackgroundURLSession;

- (BOOL)validateServerResponse:(NSDictionary *)results error:(NSError **)error;

- (NSArray *)convertServerDataSetToImojiArray:(NSDictionary *)serverResponse;

- (void)handleImojiFetchResponse:(NSArray *)imojiObjects quality:(IMImojiObjectRenderSize)quality cancellationToken:(NSOperation *)cancellationToken searchResponseCallback:(IMImojiSessionResultSetResponseCallback)searchResponseCallback imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback;

- (void)downloadImojiImageAsync:(IMMutableImojiObject *)imoji quality:(IMImojiObjectRenderSize)quality imojiIndex:(NSUInteger)imojiIndex cancellationToken:(NSOperation *)cancellationToken imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback;

- (IMMutableImojiObject *)readImojiObject:(NSDictionary *)result;

#pragma mark Auth

- (void)renewCredentials:(IMImojiSessionAsyncResponseCallback)callback;

- (void)readAuthenticationFromDictionary:(NSDictionary *)authenticationInfo;

- (BFTask *)readAuthenticationCredentials;

- (BFTask *)writeAuthenticationCredentials;

- (NSOperation *)cancellationTokenOperation;

#pragma mark Network

- (BFTask *)runPostTaskWithPath:(NSString *)path headers:(NSDictionary *)headers andParameters:(NSDictionary *)parameters;

- (BFTask *)runValidatedGetTaskWithPath:(NSString *)path andParameters:(NSDictionary *)parameters;

- (BFTask *)runValidatedPostTaskWithPath:(NSString *)path andParameters:(NSDictionary *)parameters;

- (NSDictionary *)getRequestHeaders:(NSDictionary *)additionalHeaders;

- (BFTask *)runValidatedImojiURLRequest:(NSURL *)url parameters:(NSDictionary *)parameters method:(NSString *)method headers:(NSDictionary *)headers;

- (BFTask *)runImojiURLRequest:(NSMutableURLRequest *)request headers:(NSDictionary *)headers;

- (BFTask *)runExternalURLRequest:(NSMutableURLRequest *)request headers:(NSDictionary *)headers;

- (BFTask *)validateSession;

- (NSDictionary *)getOAuthBearerHeaders;

- (void)updateImojiState:(IMImojiSessionState)newState;

- (NSString *)sessionFilePath;

@end
