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

#import "IMMutableCategoryObject.h"
#import "IMImojiObject.h"


@implementation IMMutableCategoryObject {

}
- (instancetype)initWithIdentifier:(NSString *)identifier
                             order:(NSUInteger)order
                      previewImoji:(IMImojiObject *)previewImoji
                          priority:(NSUInteger)priority
                             title:(NSString *)title {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _order = order;
        _previewImoji = previewImoji;
        _priority = priority;
        _title = title;
    }

    return self;
}

- (NSString *)identifier {
    return _identifier;
}

- (NSUInteger)order {
    return _order;
}

- (IMImojiObject *)previewImoji {
    return _previewImoji;
}

- (NSUInteger)priority {
    return _priority;
}

- (NSString *)title {
    return _title;
}


+ (instancetype)objectWithIdentifier:(NSString *)identifier
                               order:(NSUInteger)order
                        previewImoji:(IMImojiObject *)previewImoji
                            priority:(NSUInteger)priority
                               title:(NSString *)title {
    return [[self alloc] initWithIdentifier:identifier order:order previewImoji:previewImoji priority:priority title:title];
}

@end
