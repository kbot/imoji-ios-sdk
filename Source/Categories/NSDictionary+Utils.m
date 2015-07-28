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

#import "NSDictionary+Utils.h"


@implementation NSDictionary (Utils)

- (NSString *)im_checkedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    NSString *val = [self im_checkedStringForKey:key];
    return val ? val : defaultValue;
}

- (NSString *)im_checkedStringForKey:(NSString *)key {
    id value = self[key];
    return value != nil && [value isKindOfClass:[NSString class]] ? value : nil;
}

- (NSArray *)im_checkedArrayForKey:(NSString *)key defaultValue:(NSArray *)defaultValue {
    NSArray *val = [self im_checkedArrayForKey:key];
    return val ? val : defaultValue;
}

- (NSArray *)im_checkedArrayForKey:(NSString *)key {
    id value = self[key];
    return value != nil && [value isKindOfClass:[NSArray class]] ? value : nil;
}

- (NSNumber *)im_checkedNumberForKey:(NSString *)key defaultValue:(NSNumber *)defaultValue {
    NSNumber *val = [self im_checkedNumberForKey:key];
    return val ? val : defaultValue;
}

- (NSNumber *)im_checkedNumberForKey:(NSString *)key {
    id value = self[key];
    return value != nil && [value isKindOfClass:[NSNumber class]] ? value : nil;
}

- (BOOL)isEmpty {
    return self.count == 0;
}

@end
