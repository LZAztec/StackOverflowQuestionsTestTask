//
// Created by Aztec on 06.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowResponseBaseModel.h"

@implementation StackOverflowResponseBaseModel

+ (NSDictionary*)mts_mapping
{
    return @{
            @"items" : mts_key(items),
            @"has_more" : mts_key(hasMore),
            @"quota_max" : mts_key(quotaMax),
            @"quota_remaining" : mts_key(quotaRemaining),
    };
}

- (void)setValuesFromDictionary:(NSDictionary *)dictionary {
    [self mts_setValuesForKeysWithDictionary:dictionary];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ Items count: %lu, hasMore: %@, quotaMax: %@, quotaRemaining: %@", self.debugName, (unsigned long)self.items.count, self.hasMore, self.quotaMax, self.quotaRemaining];
}

@end