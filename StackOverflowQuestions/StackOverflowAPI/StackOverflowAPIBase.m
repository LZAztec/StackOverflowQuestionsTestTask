//
// Created by Aztec on 05.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowAPIBase.h"
#import "StackOverflowResponseBaseModel.h"

@interface StackOverflowAPIBase ()

@property (nonatomic, strong, readwrite) NSString *methodGroup;

@end

@implementation StackOverflowAPIBase

- (id)init {
    self = [super init];
    if (self) {
        self.methodGroup = [[NSStringFromClass(self.class) substringFromIndex:@"StackOverflowAPI".length] lowercaseString];
    }
    return self;
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
                                     andParameters:methodParameters];
}

- (NSString *)implode:(NSArray *)array
{
    return [[array valueForKey:@"description"] componentsJoinedByString:@";"];
}


@end