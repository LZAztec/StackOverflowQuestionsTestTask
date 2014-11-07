//
// Created by Aztec on 05.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowAPIBase_.h"

@interface StackOverflowAPIQuestions : StackOverflowAPIBase_

- (StackOverflowRequest *)questionsByTags:(NSArray *)tags page:(NSInteger)page limit:(NSInteger)limit;
- (StackOverflowRequest *)answersByQuestionIds:(NSArray *)ids page:(NSInteger)page limit:(NSInteger)limit;

@end