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

@end

@implementation SettingsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.simulateQueriesSwitch.on = [[UserSettings sharedInstance] getSimulateQueriesState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)simulateQueriesChanged:(id)sender;
{
    NSLog(@"Setting simulation to %@", (self.simulateQueriesSwitch.isOn)?@"YES":@"NO");
    [[UserSettings sharedInstance] setSimulateQueriesState:self.simulateQueriesSwitch.isOn];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers[0] class] == [QuestionListViewController class]) {
        [self.navigationController.viewControllers[0] refreshFirstPage];
    }
    [super viewWillDisappear:animated];
}

@end
