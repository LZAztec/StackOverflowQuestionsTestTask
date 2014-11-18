//
// Created by Aztec on 12.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowQuestionsByTagsItemResponse.h"


@implementation StackOverflowQuestionsByTagsItemResponse

+ (NSDictionary*)mts_mapping
{
    return @{
            @"owner.display_name": mts_key(authorName),
            @"answer_count": mts_key(counter),
            @"creation_date": mts_key(creationDate),
            @"last_edit_date": mts_key(lastModificationDate),
            @"is_answered": mts_key(status),
            @"title": mts_key(title),
            @"body": mts_key(body),
            @"question_id": mts_key(dataId),
            @"link": mts_key(link),
    };
}

@end