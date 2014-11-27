//
// Created by Aztec on 27.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>

// Paging parameters
FOUNDATION_EXTERN NSString *const kStackOverflowAPIDataPerPageKey;
FOUNDATION_EXTERN NSString *const kStackOverflowAPIPageKey;

// StackOverflow SDK Errors
typedef NS_ENUM(NSInteger, StackOverflowError) {
    StackOverflowErrorRequestCancelled,
    StackOverflowErrorAPIResponseWithError
};
