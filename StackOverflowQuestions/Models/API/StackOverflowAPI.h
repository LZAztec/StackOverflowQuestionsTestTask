//
//  StackOverflowAPI.h
//  StackOverflowQuestions
//
//  Created by Aztec on 07.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

@protocol StackOverflowAPIDelegate <NSObject>

@optional
- (void)handleError:(NSError *)error;
- (void)handleQuestionsByTagsResponse:(NSDictionary *)response;
- (void)handleAnswersByQuestionIdsResponse:(NSDictionary *)response;

@end

@interface StackOverflowAPI: NSObject <NSURLConnectionDelegate>
{
    NSMutableData *_responseData;
}

@property (weak) id <StackOverflowAPIDelegate> delegate;
@property BOOL simulateQueries;

- (instancetype)initWithDelegate:(id <StackOverflowAPIDelegate>)delegate;

- (void)getQuestionsByTags:(NSArray *)tags page:(NSNumber *)page limit:(NSNumber *)limit;

- (void)getAnswersByQuestionIds:(NSArray *)ids page:(NSNumber *)page limit:(NSNumber *)limit;

@end