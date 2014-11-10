//
// Created by Aztec on 05.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackOverflowObject.h"
#import "StackOverflowRequest.h"
#import "UserSettings.h"


@interface StackOverflowAPIBase : StackOverflowObject {
@private
    NSString *_methodGroup;  ///< Selected methods group
}

/**
Return group name for current methods builder
@return name of methods group, e.g. questions etc.
*/
- (NSString *)getMethodGroup;

/**
Builds request and return it for configure and loading
@param methodName Selected method name
@param methodParameters Selected method parameters
@return request to configure and load
*/
- (StackOverflowRequest *)prepareRequestWithMethodName:(NSString *)methodName
                                         andParameters:(NSDictionary *)methodParameters;

/**
Builds request and return it for configure and loading
@param methodName Selected method name
@param methodParameters Selected method parameters
@param httpMethod HTTP method for loading request. E.g. GET or POST
@return request to configure and load
*/
- (StackOverflowRequest *)prepareRequestWithMethodName:(NSString *)methodName
                                         andParameters:(NSDictionary *)methodParameters
                                         andHttpMethod:(NSString *)httpMethod;

/**
Implode array of params with ";" to use it in API-request uri
*/
- (NSString *)implode:(NSArray *)array;

@end