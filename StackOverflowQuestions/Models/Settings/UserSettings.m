//
//  UserSettings.m
//  StackOverflowQuestions
//
//  Created by Aztec on 24.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "UserSettings.h"

static NSString *const kSimulateQueriesKey = @"SimulateQueries";

@implementation UserSettings

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    
    if (!self){
        return nil;
    }
    
    self.settings = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaultValues = [@{kSimulateQueriesKey : @YES} mutableCopy];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];

    return self;
}

- (void)setSimulateQueries:(BOOL)state
{
    [self.settings setBool:state forKey:kSimulateQueriesKey];
    [self.settings synchronize];
}

- (BOOL)simulateQueries
{
    BOOL simulateState = [self.settings boolForKey:kSimulateQueriesKey];
    NSLog(@"Current state: %@", (simulateState)?@"yes":@"no");
    return [self.settings boolForKey:kSimulateQueriesKey];
}

@end
