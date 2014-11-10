//
// Created by Aztec on 06.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MappingModel.h"
#import "StackOverflowResponseModelItem.h"

@protocol StackOverflowResponseModelProtocol

@required
- (id)initWithDictionary:(NSDictionary *)dictionary mappingMethod:(NSString *) mappingMethod;

@end

@interface StackOverflowResponseModel : MappingModel <StackOverflowResponseModelProtocol>

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSNumber *hasMore;
@property (strong, nonatomic) NSNumber *quotaMax;
@property (strong, nonatomic) NSNumber *quotaRemaining;

@end

