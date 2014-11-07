//
// Created by Aztec on 05.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackOverflowAPIQuestions.h"

@interface StackOverflowAPINew : NSObject

/**
https://api.stackexchange.com/docs
Returns object for preparing requests to questions part of API
*/
+ (StackOverflowAPIQuestions *)questions;

@end