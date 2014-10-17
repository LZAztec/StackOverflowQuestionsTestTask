//
//  DefaultDateTimeFormatter.h
//  StackOverflowQuestions
//
//  Created by Aztec on 17.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormatterFactory : NSObject

+ (NSDateFormatter *)getDefaultDateTimeFormatter;

@end
