//
//  NSObject+NSString_ReplaceHtml.m
//  StackOverflowQuestions
//
//  Created by Aztec on 13.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "NSString+StripHtml.h"

@implementation NSString (StripHtml)

-(NSString *) stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

@end
