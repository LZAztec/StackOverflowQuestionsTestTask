//
// Created by Aztec on 12.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackOverflowObject.h"

@interface StackOverflowResponseFactory : StackOverflowObject

+ (id)responseWithDictionary:(NSDictionary *)dictionary method:(NSString *)method model:(Class)model;

@end