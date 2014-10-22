//
// Created by Aztec on 22.10.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>

//Constants
#define kFormatHelperSecond 1
#define kFormatHelperMinute (60 * kFormatHelperSecond)
#define kFormatHelperHour (60 * kFormatHelperMinute)
#define kFormatHelperDay (24 * kFormatHelperHour)
#define kFormatHelperMonth (30 * kFormatHelperDay)

@interface FormatHelper : NSObject

+ (NSString *)formatDateFuzzy:(NSDate *)date;
+ (NSString *)formatTimestampDefault:(NSNumber *)timestamp;

@end