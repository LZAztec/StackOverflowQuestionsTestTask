//
//  ViewController.h
//  StackOverflowQuestions
//
//  Created by Aztec on 07.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StackOverflowAPI.h"
#import "TagPickerViewController.h"

@interface QuestionListViewController : UITableViewController <TagPickerViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *changeTagButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (strong, nonatomic) NSMutableArray *questions;

- (IBAction) changeTagPressed:(id)sender;
- (void)refreshFirstPage;

@end

