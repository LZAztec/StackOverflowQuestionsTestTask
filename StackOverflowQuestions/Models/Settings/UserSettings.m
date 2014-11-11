//
//  UserSettings.m
//  StackOverflowQuestions
//
//  Created by Aztec on 24.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "UserSettings.h"

static NSString *const kSimulateQueriesKey = @"SimulateQueries";
static NSString *const kUseUIActivityControllerForSharingKey = @"UseUIActivityControllerForSharing";

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
    // TODO Add check on iOS version. disable useUIActivityControllerSwitch if iOS < 6 and set parameter to "false"
    NSMutableDictionary *defaultValues = [@{
            kSimulateQueriesKey : @YES,
            kUseUIActivityControllerForSharingKey : @YES
    } mutableCopy];

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];

    return self;
}

- (void)setSimulateQueries:(BOOL)state
{
    [self setBoolState:state forKey:kSimulateQueriesKey];
}

- (BOOL)simulateQueries
{
    return [self boolStateForKey:kSimulateQueriesKey];
}

- (void)setUseUIActivityControllerForSharing:(BOOL)state
{
    [self setBoolState:state forKey:kUseUIActivityControllerForSharingKey];
}

- (BOOL)useUIActivityControllerForSharing
{
    return [self boolStateForKey:kUseUIActivityControllerForSharingKey];
}

#pragma mark - Private methods

- (void)logState:(BOOL)state forKey:(NSString *)key
{
    NSLog(@"%@ state: %@", key, (state) ? @"YES" : @"NO");
}

- (BOOL)boolStateForKey:(NSString *)key
{
    BOOL state = [self.settings boolForKey:key];
    [self logState:state forKey:key];
    return state;
}

- (void)setBoolState:(BOOL)state forKey:(NSString *)key
{
    [self.settings setBool:state forKey:key];
    [self.settings synchronize];
}

@end
