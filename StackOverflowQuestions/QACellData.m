//
// Created by Aztec on 22.10.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QACellData.h"

@implementation QACellData

- (instancetype)initWithAuthorName:(NSString *)authorName
                           counter:(NSNumber *)counter
                      creationDate:(NSDate *)creationDate
                  lastModification:(NSDate *)lastModification
                            status:(NSNumber *)status
                              text:(NSString *)text
                                id:(NSString *)id
                              type:(NSString *)type
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.authorName = authorName;
    self.counter = counter;
    self.creationDate = creationDate;
    self.lastModification = lastModification;
    self.status = status;
    self.text = text;
    self.id = id;
    self.type = type;

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    QACellData *cellDataCopy = [QACellData new];

    cellDataCopy.authorName = self.authorName;
    cellDataCopy.counter = self.counter;
    cellDataCopy.creationDate = self.creationDate ;
    cellDataCopy.lastModification = self.lastModification;
    cellDataCopy.status = self.status;
    cellDataCopy.text = self.text;
    cellDataCopy.id = self.id;
    cellDataCopy.type = self.type;

    return cellDataCopy;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ id: %@, type: %@, AuthorName: %@, counter: %@, CreationDate: %@, ModificationDate: %@, status: %@, text: %@ }", self.id, self.type, self.authorName, self.counter, self.creationDate, self.lastModification, self.status, self.text];
}
@end