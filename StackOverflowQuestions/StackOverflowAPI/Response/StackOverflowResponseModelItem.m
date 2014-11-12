//
// Created by Aztec on 22.10.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowResponseModelItem.h"

@implementation StackOverflowResponseModelItem

- (id)copyWithZone:(NSZone *)zone
{
    StackOverflowResponseModelItem *cellDataCopy = [StackOverflowResponseModelItem new];

    cellDataCopy.authorName = self.authorName;
    cellDataCopy.counter = self.counter;
    cellDataCopy.creationDate = self.creationDate ;
    cellDataCopy.lastModificationDate = self.lastModificationDate;
    cellDataCopy.status = self.status;
    cellDataCopy.title = self.title;
    cellDataCopy.body = self.body;
    cellDataCopy.dataId = self.dataId;
    cellDataCopy.type = self.type;
    cellDataCopy.link = self.link;

    return cellDataCopy;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<StackOverflowResponseModelItem : %p> { dataId: %@, type: %@, AuthorName: %@, counter: %@, CreationDate: %@, ModificationDate: %@, status: %@, title: \"%@\", body: \"%@\",link: %@ }", self, self.dataId, self.type, self.authorName, self.counter, self.creationDate, self.lastModificationDate, self.status, self.title, self.body, self.link];
}

- (NSDictionary *)keyToClassMappingRulesUsingMappingMethod:(NSString *)mappingMethod
{
    return nil;
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
                @"question_id": @"id",
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
                @"answer_id": @"id",
        };
    }
}

@end