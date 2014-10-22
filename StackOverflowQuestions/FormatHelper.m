//
// Created by Aztec on 22.10.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "FormatHelper.h"
#import "FormatterFactory.h"


@implementation FormatHelper

+ (NSString *)formatDateFuzzy:(NSDate *)date
{
    NSDate *dateNow = [NSDate date];

    //Calculate the delta in seconds between the two dates
    NSTimeInterval delta = [dateNow timeIntervalSinceDate:date];

    if (delta < 1 * MINUTE) {
        return delta == 1 ? @"one second ago" : [NSString stringWithFormat:@"%d seconds ago", (int) delta];
    }
    if (delta < 2 * MINUTE) {
        return @"a minute ago";
    }
    if (delta < 45 * MINUTE) {
        int minutes = (int) floor((double) delta / MINUTE);
        return [NSString stringWithFormat:@"%d minutes ago", minutes];
    }
    if (delta < 90 * MINUTE) {
        return @"an hour ago";
    }
    if (delta < 24 * HOUR) {
        int hours = (int) floor((double) delta / HOUR);
        return [NSString stringWithFormat:@"%d hours ago", hours];
    }
    if (delta < 48 * HOUR) {
        return @"yesterday";
    }
    if (delta < 30 * DAY) {
        int days = (int) floor((double) delta / DAY);
        return [NSString stringWithFormat:@"%d days ago", days];
    }
    if (delta < 12 * MONTH) {
        int months = (int) floor((double) delta / MONTH);
        return months <= 1 ? @"one month ago" : [NSString stringWithFormat:@"%d months ago", months];
    }
    else {
        int years = (int) floor((double) delta / MONTH / 12.0);
        return years <= 1 ? @"one year ago" : [NSString stringWithFormat:@"%d years ago", years];
    }

}

+ (NSString *)formatTimestampDefault:(NSNumber *)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [timestamp doubleValue]];
    return [[FormatterFactory getDefaultDateTimeFormatter] stringFromDate:date];
}

@end