//
//  SettingsController.h
//  StackOverflowQuestions
//
//  Created by Aztec on 24.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsController : UIViewController

@property (nonatomic, retain) IBOutlet UISwitch *simulateQueriesSwitch;

- (IBAction)simulateQueriesChanged:(id)sender;

@end
