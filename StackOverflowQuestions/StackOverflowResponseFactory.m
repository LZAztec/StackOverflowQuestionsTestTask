//
// Created by Aztec on 12.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowResponseFactory.h"
#import "StackOverflowResponseBaseModel.h"
#import "StackOverflowQuestionsByTagsResponse.h"
#import "StackOverflowAnswersByQuestionIdsResponse.h"


@implementation StackOverflowResponseFactory

+ (id)responseWithDictionary:(NSDictionary *)dictionary method:(NSString *)method model:(Class)model {

    id object = nil;

    if ([model conformsToProtocol:@protocol(StackOverflowResponseModelProtocol)]) {
        object = [[model alloc] init];
    } else if ([method isEqualToString:@"questions"]) {
        object = [[StackOverflowQuestionsByTagsResponse alloc] init];
    } else {
        object = [[StackOverflowAnswersByQuestionIdsResponse alloc] init];
    }

    if ([object conformsToProtocol:@protocol(StackOverflowResponseModelProtocol)]) {
        [object setValuesFromDictionary:dictionary];
    }

    return object;
}

@end