//
//  DefaultDateTimeFormatter.m
//  StackOverflowQuestions
//
//  Created by Aztec on 17.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "FormatterFactory.h"

@implementation FormatterFactory

+ (NSDateFormatter *)defaultDateTimeFormatter
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NSDateFormatter alloc] init];
        [sharedInstance setDateFormat:@"yyyy-MM-dd HH:mm"];
    });
    
    return sharedInstance;
}

@end
