//
//  UITextView+Additions.m
//  StackOverflowQuestions
//
//  Created by Aztec on 20.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "UITextView+Additions.h"

@implementation UITextView (Additions)

- (NSRange)visibleTextRange;
{
    
    CGRect bounds           = self.bounds;
    CGSize textSize         = [self.text sizeWithFont:self.font constrainedToSize:bounds.size];
    
    UITextPosition *start   = [self characterRangeAtPoint:bounds.origin].start;
    UITextPosition *end     = [self characterRangeAtPoint:CGPointMake(textSize.width, textSize.height)].end;
    NSUInteger startPoint   = [self offsetFromPosition:self.beginningOfDocument toPosition:start];
    NSUInteger endPoint     = [self offsetFromPosition:start toPosition:end];
    
    return NSMakeRange(startPoint, endPoint);
}

@end
