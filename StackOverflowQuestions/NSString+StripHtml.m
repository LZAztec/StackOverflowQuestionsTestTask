//
//  NSObject+NSString_ReplaceHtml.m
//  StackOverflowQuestions
//
//  Created by Aztec on 13.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "NSString+StripHtml.h"

@implementation NSString (StripHtml)

- (NSString *)stringByStrippingHTML {
    return [self stringByReplacingOccurrencesOfRegex:@"<[^>]+>" withString:@""];
}

- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regex withString:(NSString *)replacement
{
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:regex options:NSRegularExpressionSearch]).location != NSNotFound){
        s = [s stringByReplacingCharactersInRange:r withString:replacement];
    }
    return s;
}


@end
