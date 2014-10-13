//
//  StackOverflowAPI.h
//  StackOverflowQuestions
//
//  Created by Aztec on 07.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

@interface  StackOverflowAPI: NSObject

- (void)getQuestionsByTags:(NSArray *)tags withResponseHandler:(id)handler andSelector:(SEL)selector;
- (void)getAnswersInfoByQuestionIds:(NSArray *)ids withResponseHandler:(id)handler andSelector:(SEL)selector;

@end
