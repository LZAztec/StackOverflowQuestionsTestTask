//
// Created by Aztec on 05.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowAPIQuestions.h"

@implementation StackOverflowAPIQuestions

- (StackOverflowRequest *)questionsByTags:(NSArray *)tags page:(NSInteger)page limit:(NSInteger)limit;
{
    NSDictionary *params = @{
            @"page" : @(page),
            @"pagesize" : @(limit),
            @"order" : @"desc",
            @"sort" : @"creation",
            @"tagged" : [self implode:tags],
            @"site" : @"stackoverflow",
            @"filter" : @"withbody"
    };

    return [self prepareRequestWithMethodName:nil andParameters:params];
}

- (StackOverflowRequest *)answersByQuestionIds:(NSArray *)ids page:(NSInteger)page limit:(NSInteger)limit;
{
    NSDictionary *params = @{
            @"page" : @(page),
            @"pagesize" : @(limit),
            @"order" : @"desc",
            @"sort" : @"creation",
            @"site" : @"stackoverflow",
            @"filter" : @"withbody"
    };

    NSString *methodName = [NSString stringWithFormat:@"%@/answers", [self implode:ids]];

    return [self prepareRequestWithMethodName:methodName andParameters:params];
}

@end