//
// Created by Aztec on 06.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Motis/Motis.h>
#import "StackOverflowResponseBaseModelItem.h"

@protocol StackOverflowResponseModelProtocol

@required
- (void)setValuesFromDictionary:(NSDictionary *)dictionary;

@end

@interface StackOverflowResponseBaseModel : StackOverflowObject <StackOverflowResponseModelProtocol>

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSNumber *hasMore;
@property (strong, nonatomic) NSNumber *quotaMax;
@property (strong, nonatomic) NSNumber *quotaRemaining;

@end

