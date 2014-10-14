//
//  NSObject+NSString_ReplaceHtml.h
//  StackOverflowQuestions
//
//  Created by Aztec on 13.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StripHtml)

- (NSString *)stringByStrippingHTML;
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)regex withString:(NSString *)replacement;

@end
