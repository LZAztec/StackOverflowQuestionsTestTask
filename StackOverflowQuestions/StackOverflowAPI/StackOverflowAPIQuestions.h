//
// Created by Aztec on 05.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowAPIBase.h"

@interface StackOverflowAPIQuestions : StackOverflowAPIBase

- (StackOverflowRequest *)questionsByTags:(NSArray *)tags;
- (StackOverflowRequest *)answersByQuestionIds:(NSArray *)ids;

@end