//
// Created by Aztec on 06.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowResponseModel.h"


@implementation StackOverflowResponseModel

- (NSDictionary *)keyToClassMappingRulesUsingMappingMethod:(NSString *)mappingMethod
{
    return @{
            @"items":[StackOverflowResponseModelItem class]
    };
}

- (NSDictionary *)keyToPropertyNameReplacementRulesUsingMappingMethod:(NSString *)mappingMethod
{
    return @{
            @"has_more": @"hasMore",
            @"quota_max": @"quotaMax",
            @"quota_remaining": @"quotaRemaining",
    };
}

- (id)initWithDictionary:(NSDictionary *)dictionary mappingMethod:(NSString *) mappingMethod;
{
    return [StackOverflowResponseModel mapObjectFromDictionary:dictionary mappingMethod:mappingMethod];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<StackOverflowResponseModel:%p>Items count: %lu, hasMore: %@, quotaMax: %@, quotaRemaining: %@", self, (unsigned long)self.items.count, self.hasMore, self.quotaMax, self.quotaRemaining];
}

@end