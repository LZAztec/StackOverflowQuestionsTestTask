//
// Created by Aztec on 22.10.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kCellDataQuestionType = @"question";
static NSString *const kCellDataAnswerType = @"answer";

@interface StackOverflowResponseData : NSObject <NSCopying>

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

@class StackOverflowResponseData;

@protocol StackOverflowResponseDataContainer
@required
- (void)setCellData:(StackOverflowResponseData *)data;
@end