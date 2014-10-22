//
// Created by Aztec on 22.10.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>

//Constants
#define SECOND 1
#define MINUTE (60 * SECOND)
#define HOUR (60 * MINUTE)
#define DAY (24 * HOUR)
#define MONTH (30 * DAY)

@interface FormatHelper : NSObject

+ (NSString *)formatDateFuzzy:(NSDate *)date;
+ (NSString *)formatTimestampDefault:(NSNumber *)timestamp;

@end