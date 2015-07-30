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

#import <Bolts/BFExecutor.h>
#import <Bolts/BFTaskCompletionSource.h>
#import "BFTask+Utils.h"
#import "BFExecutor.h"


@implementation BFTask (Utils)

+ (BFTask *)im_concurrentBackgroundTaskWithBlock:(BFContinuationBlock)block {
    return [[BFTask taskWithDelay:0] continueWithExecutor:[BFTask im_concurrentBackgroundExecutor] withBlock:block];
}

+ (BFExecutor *)im_concurrentBackgroundExecutor {
    static BFExecutor *executor = nil;
    static dispatch_once_t backgroundPredicate;

    dispatch_once(&backgroundPredicate, ^{
        executor = [BFExecutor executorWithDispatchQueue:[BFTask backgroundQueue]];
    });

    return executor;
}

+ (dispatch_queue_t)backgroundQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t queuePredicate;

    dispatch_once(&queuePredicate, ^{
        queue = dispatch_queue_create("com.imoji.background.queue.concurrent", DISPATCH_QUEUE_CONCURRENT);
    });

    return queue;
}

+ (BFTask *)im_serialBackgroundTaskWithBlock:(BFContinuationBlock)block {
    return [[BFTask taskWithDelay:0] continueWithExecutor:[BFTask im_serialBackgroundExecutor] withBlock:block];
}

+ (BFExecutor *)im_serialBackgroundExecutor {
    static BFExecutor *executor = nil;
    static dispatch_once_t serialBackgroundPredicate;

    dispatch_once(&serialBackgroundPredicate, ^{
        executor = [BFExecutor executorWithDispatchQueue:[BFTask serialBackgroundQueue]];
    });

    return executor;
}

+ (dispatch_queue_t)serialBackgroundQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t serialQueuePredicate;

    dispatch_once(&serialQueuePredicate, ^{
        queue = dispatch_queue_create("com.imoji.background.queue.serial", DISPATCH_QUEUE_SERIAL);
    });

    return queue;
}

@end
