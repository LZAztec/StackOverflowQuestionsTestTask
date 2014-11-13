//
// Created by Aztec on 22.10.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormatHelper.h"
#import "FormatterFactory.h"
#import "NSString+HTML.h"


@implementation FormatHelper

+ (NSString *)formatDateFuzzy:(NSDate *)date
{
    if (!date) {
        return @"";
    }

    NSDate *dateNow = [NSDate date];

    //Calculate the delta in seconds between the two dates
    NSTimeInterval delta = [dateNow timeIntervalSinceDate:date];

    if (delta < 1 * kFormatHelperMinute) {
        return delta == 1 ? @"one second ago" : [NSString stringWithFormat:@"%d seconds ago", (int) delta];
    }
    if (delta < 2 * kFormatHelperMinute) {
        return @"a minute ago";
    }
    if (delta < 45 * kFormatHelperMinute) {
        int minutes = (int) floor((double) delta / kFormatHelperMinute);
        return [NSString stringWithFormat:@"%d minutes ago", minutes];
    }
    if (delta < 90 * kFormatHelperMinute) {
        return @"an hour ago";
    }
    if (delta < 24 * kFormatHelperHour) {
        int hours = (int) floor((double) delta / kFormatHelperHour);
        return [NSString stringWithFormat:@"%d hours ago", hours];
    }
    if (delta < 48 * kFormatHelperHour) {
        return @"yesterday";
    }
    if (delta < 30 * kFormatHelperDay) {
        int days = (int) floor((double) delta / kFormatHelperDay);
        return [NSString stringWithFormat:@"%d days ago", days];
    }
    if (delta < 12 * kFormatHelperMonth) {
        int months = (int) floor((double) delta / kFormatHelperMonth);
        return months <= 1 ? @"one month ago" : [NSString stringWithFormat:@"%d months ago", months];
    }
    else {
        int years = (int) floor((double) delta / kFormatHelperMonth / 12.0);
        return years <= 1 ? @"one year ago" : [NSString stringWithFormat:@"%d years ago", years];
    }

}

+ (NSString *)formatTimestampDefault:(NSNumber *)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [timestamp doubleValue]];
    return [[FormatterFactory defaultDateTimeFormatter] stringFromDate:date];
}

+ (NSMutableAttributedString *)formatText:(NSString *)text withCodeTagBackgroundColor:(UIColor *)bgColor textColor:(UIColor *)textColor
{
    // Replace tags (<code> & </code>) with non html compliant analog (%code% & %/code%)
    text = [text stringByReplacingOccurrencesOfString:@"<code>" withString:@"%code%"];
    text = [text stringByReplacingOccurrencesOfString:@"</code>" withString:@"%/code%"];

    if (text.length == 0) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }

    NSMutableAttributedString *newText = [[NSMutableAttributedString alloc] initWithString:[text stringByConvertingHTMLToPlainText]];

    NSRegularExpression *regex = [self makeRegexForPattern:@"%code%.*%/code%"];

    // Find matches
    NSArray *matches = [regex matchesInString:newText.string
                                      options:NSMatchingReportProgress
                                        range:NSMakeRange(0, newText.length)];

    // Iterate through the matches and highlight them
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = match.range;
        // Decrease range to exlude tags (non html compliant analog) from highlight
        matchRange.location += 6;
        matchRange.length -= 7;

        [newText addAttribute:NSBackgroundColorAttributeName
                        value:bgColor
                        range:matchRange];
        [newText addAttribute:NSForegroundColorAttributeName
                        value:textColor
                        range:matchRange];
    }

    // Set font, notice the range is for the whole string
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    
    [newText addAttribute:NSFontAttributeName
                                   value:font
                                   range:NSMakeRange(0, [newText length])];
    
    return [FormatHelper mutableAttributedStringByReplacingPattern:@"%/{0,1}code%"
                                                       replacement:@"\n"
                                           mutableAttributedString:newText];
}

+ (NSMutableAttributedString *)mutableAttributedStringByReplacingPattern:(NSString *)pattern
                                                             replacement:(NSString *)replacement
                                                 mutableAttributedString:(NSMutableAttributedString *)attributedString
{
    NSRegularExpression *regex = [FormatHelper makeRegexForPattern:@"%/{0,1}code%"];

    NSArray *matches = [regex matchesInString:attributedString.string
                                      options:NSMatchingReportProgress
                                        range:NSMakeRange(0, attributedString.length)];

    if (matches.count > 0) {
        NSTextCheckingResult *matchCode = matches[0];
        [attributedString replaceCharactersInRange:matchCode.range withString:replacement];
        attributedString = [self mutableAttributedStringByReplacingPattern:pattern replacement:replacement mutableAttributedString:attributedString];
    }

    return attributedString;
}

// Create a regular expression with given pattern
+ (NSRegularExpression *)makeRegexForPattern:(NSString *)pattern
{
    // Create a regular expression
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;


    return [NSRegularExpression regularExpressionWithPattern:pattern
                                                     options:regexOptions
                                                       error:&error];
}

@end