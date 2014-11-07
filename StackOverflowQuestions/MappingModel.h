//
//  MappingModel.h
//  SimpleMapping
//
//  Created by iN on 20.05.13.
//  Copyright (c) 2013 Cats. All rights reserved.
//
//  @link https://github.com/indisee/iOSTinyMapper
//
//
// Modified by Aztec on 06.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackOverflowObject.h"

@interface MappingModel : StackOverflowObject

+ (instancetype)mapObjectFromDictionary:(NSDictionary *)data mappingMethod:(NSString *)mappingMethod;

+ (NSArray *)mapArrayOfObjects:(NSArray *)data mappingMethod:(NSString *)mappingMethod;

//protected methods
- (NSDictionary *)keyToClassMappingRulesUsingMappingMethod:(NSString *)mappingMethod;
- (NSDictionary *)keyToPropertyNameReplacementRulesUsingMappingMethod:(NSString *)mappingMethod;

@end