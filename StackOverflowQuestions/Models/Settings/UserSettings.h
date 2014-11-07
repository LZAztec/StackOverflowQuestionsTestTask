//
//  UserSettings.h
//  StackOverflowQuestions
//
//  Created by Aztec on 24.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject

@property (strong, nonatomic) NSUserDefaults *settings;
@property (assign, nonatomic) BOOL simulateQueries;

+ (instancetype)sharedInstance;
- (instancetype)init;


@end
