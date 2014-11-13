//
// Created by Aztec on 12.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowAnswersByQuestionIdsResponse.h"
#import "StackOverflowAnswersByQuestionIdsItemResponse.h"


@implementation StackOverflowAnswersByQuestionIdsResponse

+ (NSDictionary*)mts_arrayClassMapping
{
    return @{mts_key(items) : StackOverflowAnswersByQuestionIdsItemResponse.class};
}

@end