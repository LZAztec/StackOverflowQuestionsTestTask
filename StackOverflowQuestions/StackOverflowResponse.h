//
// Created by Aztec on 05.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackOverflowObject.h"
#import "StackOverflowResponseModel.h"

@class StackOverflowRequest;

@interface StackOverflowResponse : StackOverflowObject

/// Request which caused response
@property (nonatomic, weak) StackOverflowRequest *request;
/// Json content of response. Can be array or object.
@property (nonatomic, strong) NSDictionary *json;
/// Model parsed from response
@property (nonatomic, strong) StackOverflowResponseModel *parsedModel;

@end