//
// Created by Aztec on 22.10.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowResponseBaseModelItem.h"

@implementation StackOverflowResponseBaseModelItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ { dataId: %@, type: %@, AuthorName: %@, counter: %@, CreationDate: %@, ModificationDate: %@, status: %@, title: \"%@\", body: \"%@\",link: %@ }", self.debugName, self.dataId, self.type, self.authorName, self.counter, self.creationDate, self.lastModificationDate, self.status, self.title, self.body, self.link];
}

- (NSDictionary *)keyToPropertyNameReplacementRulesUsingMappingMethod:(NSString *)mappingMethod
{

    if ([mappingMethod isEqualToString:@"questions"]){
        return @{
                @"owner.display_name": @"authorName",
                @"answer_count": @"counter",
                @"creation_date": @"creationDate",
                @"last_edit_date": @"lastModificationDate",
                @"is_answered": @"status",
                @"title": @"title",
                @"body": @"body",
                @"question_id": @"dataId",
                @"link": @"link",
        };
    } else {
        return @{
                @"owner.display_name": @"authorName",
                @"score": @"counter",
                @"creation_date": @"creationDate",
                @"last_activity_date": @"lastModificationDate",
                @"is_accepted": @"status",
                @"title": @"title",
                @"body": @"body",
                @"answer_id": @"dataId",
        };
    }
}

@end