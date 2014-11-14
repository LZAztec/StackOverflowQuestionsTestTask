//
//  SettingsController.m
//  StackOverflowQuestions
//
//  Created by Aztec on 24.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "SettingsController.h"
#import "UserSettings.h"
#import "QuestionListViewController.h"

@interface SettingsController ()

@property (strong) UserSettings *settings;

@end

@implementation SettingsController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.settings = [UserSettings sharedInstance];
    self.simulateQueriesSwitch.on = self.settings.simulateQueries;
    self.useUIActivityControllerForSharingSwitch.on = self.settings.useUIActivityControllerForSharing;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers[0] class] == [QuestionListViewController class]) {
        [self.navigationController.viewControllers[0] refreshFirstPage];
    }
    [super viewWillDisappear:animated];
}

#pragma mark - Actions
- (IBAction)simulateQueriesChanged:(id)sender;
{
    NSLog(@"Setting simulation to %@", (self.simulateQueriesSwitch.isOn)?@"YES":@"NO");
    [self.settings setSimulateQueries:self.simulateQueriesSwitch.isOn];
}

- (IBAction)useUIActivityControllerForSharingChanged:(id)sender;
{
    NSLog(@"Setting UseUIActivityControllerForSharing to %@", (self.useUIActivityControllerForSharingSwitch.isOn) ? @"YES" : @"NO");
    [self.settings setUseUIActivityControllerForSharing:self.useUIActivityControllerForSharingSwitch.isOn];
}

@end
