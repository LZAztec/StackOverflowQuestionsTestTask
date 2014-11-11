//
//  MappingModel.m
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

#import "MappingModel.h"

@implementation MappingModel

+ (instancetype)mapObjectFromDictionary:(NSDictionary *)data
                          mappingMethod:(NSString *)mappingMethod
{
    MappingModel *model = [[self alloc] init];
    for (NSString *inputKey in [data allKeys]) {
        id value = data[inputKey];

        BOOL isArray = [value isKindOfClass:[NSArray class]];

        Class classToMap = [model keyToClassMappingRulesUsingMappingMethod:mappingMethod][inputKey];

        NSString *propertyName = [[model keyToPropertyNameReplacementRulesUsingMappingMethod:mappingMethod] valueForKey:inputKey];
        propertyName = propertyName?propertyName:inputKey;

        if (classToMap) {
            if (isArray){
                [model setValue:[classToMap mapArrayOfObjects:value mappingMethod:mappingMethod] forKey:propertyName];
            } else {
                [model setValue:[classToMap mapObjectFromDictionary:value mappingMethod:mappingMethod] forKey:propertyName];
            }
        } else {
            [model setValue:value forKey:propertyName];
        }
    }
    return model;
}

+ (NSArray *)mapArrayOfObjects:(NSArray *)data
                 mappingMethod:(NSString *)mappingMethod
{
    NSMutableArray *mappedArray = [NSMutableArray arrayWithCapacity:data.count];

    for (id value in data) {
        BOOL isArray = [value isKindOfClass:[NSArray class]];
        if (isArray) {
            [mappedArray addObject:[self mapArrayOfObjects:value mappingMethod:mappingMethod]];
        } else {
            [mappedArray addObject:[self mapObjectFromDictionary:value mappingMethod:mappingMethod]];
        }
    }

    return [NSArray arrayWithArray:mappedArray];
}

- (NSDictionary *)keyToClassMappingRulesUsingMappingMethod:(NSString *)mappingMethod {
    return nil;
}

- (NSDictionary *)keyToPropertyNameReplacementRulesUsingMappingMethod:(NSString *)mappingMethod {
    return nil;
}

#pragma mark - KVC

- (id)valueForUndefinedKey:(NSString *)key
{
    [self showNotice:@"get" forKey:key];
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    [self showNotice:@"set" forKey:key];
}

#pragma mark - Service

- (void)showNotice:(NSString *)string forKey:(NSString *)key
{
    NSLog(@"Trying to %@ value. Property for key \"%@\" is undefined.", string, key);
}

@end