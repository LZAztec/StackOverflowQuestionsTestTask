//
// Created by Aztec on 12.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowQuestionsByTagsResponse.h"
#import "StackOverflowQuestionsByTagsItemResponse.h"


@implementation StackOverflowQuestionsByTagsResponse

+ (NSDictionary*)mts_arrayClassMapping
{
    return @{mts_key(items) : StackOverflowQuestionsByTagsItemResponse.class};
}

@end