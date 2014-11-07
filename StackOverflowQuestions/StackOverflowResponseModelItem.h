//
// Created by Aztec on 22.10.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackOverflowObject.h"
#import "MappingModel.h"

@interface StackOverflowResponseModelItem : MappingModel <NSCopying>

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *authorName;
@property (strong, nonatomic) NSNumber *counter;
@property (strong, nonatomic) NSDate *creationDate;
@property (strong, nonatomic) NSDate *lastModificationDate;
@property (strong, nonatomic) NSNumber *status;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSURL *link;

@end

@class StackOverflowResponseModelItem;

@protocol StackOverflowResponseModelItemContainer
@required
- (void)setCellData:(StackOverflowResponseModelItem *)data;
@end