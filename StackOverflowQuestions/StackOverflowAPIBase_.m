//
// Created by Aztec on 05.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowAPIBase_.h"
#import "StackOverflowResponseModel.h"

@implementation StackOverflowAPIBase_

- (id)init {
    self = [super init];
    if (self) {
        NSString *methodsGroup = [[NSStringFromClass(self.class) substringFromIndex:@"StackOverflowAPI".length] lowercaseString];
        [self setMethodGroup:methodsGroup];
    }
    return self;
}

- (NSString *)getMethodGroup
{
    return _methodGroup;
}

- (void)setMethodGroup:(NSString *)methodGroup
{
    _methodGroup = methodGroup;
}

- (StackOverflowRequest *)prepareRequestWithMethodName:(NSString *)methodName
                                         andParameters:(NSDictionary *)methodParameters
{
    return [self prepareRequestWithMethodName:methodName andParameters:methodParameters andHttpMethod:@"GET"];
}

- (StackOverflowRequest *)prepareRequestWithMethodName:(NSString *)methodName
                                         andParameters:(NSDictionary *)methodParameters
                                         andHttpMethod:(NSString *)httpMethod
{
    NSString *method = _methodGroup;

    if (methodName != nil){
        method = [NSString stringWithFormat:@"%@/%@", _methodGroup, methodName];
    }

    return [StackOverflowRequest requestWithMethod:method
                                     andParameters:methodParameters
                                      classOfModel:[StackOverflowResponseModel class]];
}

- (NSString *)implode:(NSArray *)array
{
    return [[array valueForKey:@"description"] componentsJoinedByString:@";"];
}


@end