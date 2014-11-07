//
// Created by Aztec on 05.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowResponse.h"
#import "StackOverflowResponseModel.h"


@implementation StackOverflowResponse

- (NSString *)description {
    return [NSString stringWithFormat:@"<StackOverflowResponse: %p; API response: %@>", self, self.json];
}

@end