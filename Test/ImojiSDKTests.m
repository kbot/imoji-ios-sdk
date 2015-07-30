//
//  ImojiSDKTests.m
//  imoji
//
//  Created by Nima on 4/14/15.
//  Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ImojiSyncSDK.h"
#import "IMImojiSession+Testing.h"
#import "BFTask.h"
#import "BFTaskCompletionSource.h"

@interface ImojiSDKTestData : NSObject

@property(nonatomic, strong) IMImojiSession *imojiSession;
@property(nonatomic, strong) NSMutableArray *imojis;

@end

@implementation ImojiSDKTestData
@end

@interface ImojiSDKTests : XCTestCase
@property(nonatomic, strong) ImojiSDKTestData *testData;
@end

@implementation ImojiSDKTests

- (void)setUp {
    [super setUp];

    static ImojiSDKTestData *testData = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        [[ImojiSDK sharedInstance] setClientId:[[NSUUID alloc] initWithUUIDString:@"748cddd4-460d-420a-bd42-fcba7f6c031b"]
                                      apiToken:@"U2FsdGVkX1/yhkvIVfvMcPCALxJ1VHzTt8FPZdp1vj7GIb+fsdzOjyafu9MZRveo7ebjx1+SKdLUvz8aM6woAw=="];

        testData = [ImojiSDKTestData new];
        testData.imojiSession = [IMImojiSession imojiSession];
        testData.imojis = [NSMutableArray new];
    });

    self.testData = testData;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_1_1_Categories {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self.testData.imojiSession getImojiCategoriesWithClassification:IMImojiSessionCategoryClassificationGeneric callback:^(NSArray *imojiCategories, NSError *error) {
        XCTAssert(error == nil, @"Server error");
        XCTAssert(imojiCategories.count > 0, @"Imoji Categories");
        dispatch_semaphore_signal(semaphore);
    }];

    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:200]];
    }
}

- (void)test_1_2_Featured {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSInteger numResults = 0;
    [self.testData.imojiSession getFeaturedImojisWithNumberOfResults:@50
                                           resultSetResponseCallback:^(NSNumber *resultCount, NSError *searchError) {
                                               XCTAssert(searchError == nil, @"Server error");
                                               XCTAssert(resultCount.integerValue > 0, @"Featured Count");

                                               numResults = resultCount.integerValue;
                                           }
                                               imojiResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *responseError) {
                                                   XCTAssert(responseError == nil, @"imoji error");
                                                   XCTAssert(imoji != nil, @"imoji existance");
                                                   XCTAssert(index >= 0, @"imoji index");

                                                   [self.testData.imojiSession renderImoji:imoji
                                                                                   options:[IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail]
                                                                                  callback:^(UIImage *image, NSError *renderError) {
                                                                                      XCTAssertNil(renderError, @"imoji rendering error");
                                                                                      [self.testData.imojis addObject:imoji];

                                                                                      if (--numResults == 0) {
                                                                                          dispatch_semaphore_signal(semaphore);
                                                                                      }
                                                                                  }];

                                               }];

    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:200]];
    }
}

- (void)test_1_3_Search {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSInteger numResults = 0;

    [self.testData.imojiSession searchImojisWithTerm:@"happy"
                                              offset:nil
                                     numberOfResults:@50
                           resultSetResponseCallback:^(NSNumber *resultCount, NSError *searchError) {
                               XCTAssert(searchError == nil, @"Server error");
                               XCTAssert(resultCount.integerValue > 0, @"Featured Count");

                               numResults = resultCount.integerValue;
                           }
                               imojiResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *responseError) {
                                   XCTAssert(responseError == nil, @"imoji error");
                                   XCTAssert(imoji != nil, @"imoji existance");
                                   XCTAssert(index >= 0, @"imoji index");

                                   [self.testData.imojiSession renderImoji:imoji
                                                                   options:[IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail]
                                                                  callback:^(UIImage *image, NSError *renderError) {
                                                                      XCTAssertNil(renderError, @"imoji rendering error");
                                                                      [self.testData.imojis addObject:imoji];

                                                                      if (--numResults == 0) {
                                                                          dispatch_semaphore_signal(semaphore);
                                                                      }
                                                                  }];
                               }];

    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:200]];
    }
}

- (void)test_1_4_CancelTask {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    IMImojiObject *imoji = self.testData.imojis.firstObject;
    XCTAssert(imoji != nil, @"imoji exists for testing");

    NSOperation *operation = [self.testData.imojiSession renderImoji:imoji
                                                             options:[IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail]
                                                            callback:^(UIImage *image, NSError *renderError) {
                                                                XCTFail("Task should have been cancelled");
                                                                dispatch_semaphore_signal(semaphore);
                                                            }];
    [operation cancel];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 1000), dispatch_get_main_queue(), ^{
        dispatch_semaphore_signal(semaphore);
    });


    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:200]];
    }
}

- (void)test_1_5_fetchMultipleImojis {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSOrderedSet *uniqueImojis = [NSOrderedSet orderedSetWithArray:self.testData.imojis];
    __block NSUInteger numResults = uniqueImojis.count;

    NSMutableOrderedSet *identifiers = [NSMutableOrderedSet orderedSetWithCapacity:numResults];
    for (IMImojiObject *imoji in uniqueImojis) {
        [identifiers addObject:imoji.identifier];
    }

    [self.testData.imojiSession fetchImojisByIdentifiers:identifiers.array
                                 fetchedResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *responseError) {
                                     XCTAssert(responseError == nil, @"imoji error");
                                     XCTAssert(imoji != nil, @"imoji existance");
                                     XCTAssert(index >= 0, @"imoji index");

                                     [self.testData.imojiSession renderImoji:imoji
                                                                     options:[IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail]
                                                                    callback:^(UIImage *image, NSError *renderError) {
                                                                        XCTAssertNil(renderError, @"imoji rendering error");
                                                                        [self.testData.imojis addObject:imoji];

                                                                        if (--numResults == 0) {
                                                                            dispatch_semaphore_signal(semaphore);
                                                                        }
                                                                    }];
                                 }];

    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:200]];
    }
}

- (void)test_1_8_clearAuth {
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [[BFTask taskWithDelay:0] continueWithBlock:^id(BFTask *task) {
        [self.testData.imojiSession clearUserSynchronizationStatus:^(BOOL successful, NSError *error) {
            XCTAssert(error == nil, @"clearUserSynchronizationStatus");

            [self.testData.imojiSession getImojiCategoriesWithClassification:IMImojiSessionCategoryClassificationGeneric callback:^(NSArray *imojiCategories, NSError *categoriesError) {
                XCTAssert(categoriesError == nil, @"getImojiCategories after clearUserSynchronizationStatus");

                source.result = @YES;
            }];
        }];

        return nil;
    }];
    
    [self runTestWithTask:source.task];
}

- (void)test_1_9_testCorruptTokenReverification {
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [[BFTask taskWithDelay:0] continueWithBlock:^id(BFTask *task) {
        [[self.testData.imojiSession performSelector:@selector(randomAuthToken)] continueWithBlock:^id(BFTask *randomAuthTokenTask) {
            [self.testData.imojiSession getImojiCategoriesWithClassification:IMImojiSessionCategoryClassificationGeneric callback:^(NSArray *imojiCategories, NSError *categoriesError) {
                XCTAssert(categoriesError == nil, @"Server error");
                XCTAssert(imojiCategories.count > 0, @"Imoji Categories");

                source.result = @YES;
            }];

            return nil;
        }];

        return nil;
    }];

    [self runTestWithTask:source.task];
}

- (void)test_1_10_requestUserSynchronization {

    NSError* error;
    [self.testData.imojiSession requestUserSynchronizationWithError:&error];

    XCTAssert(error != nil, @"app is not installed, there should be an error");
}

- (void)test_2_1_RenderSingleImojiTest {
    [self measureBlock:^{
        IMImojiObject *imoji = self.testData.imojis.firstObject;
        XCTAssert(imoji != nil, @"imoji exists for testing");

        [self.testData.imojiSession renderImoji:imoji
                                        options:[IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail]
                                       callback:^(UIImage *image, NSError *renderError) {
                                           XCTAssertNil(renderError, @"imoji rendering error");
                                       }];
    }];
}

- (void)test_2_2_RenderMultipleImojisTest {
    [self measureBlock:^{
        for (IMImojiObject *imojiObject in self.testData.imojis) {
            [self.testData.imojiSession renderImoji:imojiObject
                                            options:[IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail]
                                           callback:^(UIImage *image, NSError *renderError) {
                                               XCTAssertNil(renderError, @"imoji rendering error");
                                           }];
        }
    }];
}

- (void)runTestWithTask:(BFTask *)task {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [task continueWithBlock:^id(BFTask *completionTask) {
        dispatch_semaphore_signal(semaphore);
        return nil;
    }];

    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:200]];
    }
}

@end
