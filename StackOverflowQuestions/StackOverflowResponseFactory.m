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

//    if ([object conformsToProtocol:@protocol(StackOverflowResponseModelProtocol)]) {
    [object mts_setValuesForKeysWithDictionary:dictionary];
//    [object setValuesFromDictionary:dictionary];
//    }

    return object;
}

+ (NSArray *)itemsFromArray:(NSArray *)sourceData mappedToClass:(Class)class
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:sourceData.count];

    if  ([sourceData isKindOfClass:[NSArray class]]) {
        [sourceData enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                id object = [[class alloc] init];
                [object mts_setValuesForKeysWithDictionary:obj];
                [result addObject:object];
            }
        }];
    }

    return [result copy];
}

@end