//
// Created by Aztec on 12.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowAnswersByQuestionIdsItemResponse.h"


@implementation StackOverflowAnswersByQuestionIdsItemResponse

+ (NSDictionary*)mts_mapping
{
    return @{
            @"owner.display_name": mts_key(authorName),
            @"score": mts_key(counter),
            @"creation_date": mts_key(creationDate),
            @"last_activity_date": mts_key(lastModificationDate),
            @"is_accepted": mts_key(status),
            @"title": mts_key(title),
            @"body": mts_key(body),
            @"answer_id": mts_key(dataId),
    };
}

@end