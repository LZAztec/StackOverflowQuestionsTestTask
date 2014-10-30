//
// Created by Aztec on 22.10.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowResponseData.h"

@implementation StackOverflowResponseData

- (id)copyWithZone:(NSZone *)zone
{
    StackOverflowResponseData *cellDataCopy = [StackOverflowResponseData new];

    cellDataCopy.authorName = self.authorName;
    cellDataCopy.counter = self.counter;
    cellDataCopy.creationDate = self.creationDate ;
    cellDataCopy.lastModificationDate = self.lastModificationDate;
    cellDataCopy.status = self.status;
    cellDataCopy.title = self.title;
    cellDataCopy.body = self.body;
    cellDataCopy.id = self.id;
    cellDataCopy.type = self.type;
    cellDataCopy.link = self.link;

    return cellDataCopy;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ id: %@, type: %@, AuthorName: %@, counter: %@, CreationDate: %@, ModificationDate: %@, status: %@, title: \"%@\", body: \"%@\",link: %@ }", self.id, self.type, self.authorName, self.counter, self.creationDate, self.lastModificationDate, self.status, self.title, self.body, self.link];
}

@end