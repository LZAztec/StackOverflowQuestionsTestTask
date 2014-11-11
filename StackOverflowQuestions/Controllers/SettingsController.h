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
@property (nonatomic, retain) IBOutlet UISwitch *useUIActivityControllerForSharingSwitch;

- (IBAction)simulateQueriesChanged:(id)sender;
- (IBAction)useUIActivityControllerForSharingChanged:(id)sender;

@end
