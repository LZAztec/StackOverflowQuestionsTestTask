//
// Created by Aztec on 05.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowObject.h"


@implementation StackOverflowObject

- (NSString *)debugName {
    return [NSString stringWithFormat:@"<%@ : %p>", NSStringFromClass(self.class), self];
}

@end