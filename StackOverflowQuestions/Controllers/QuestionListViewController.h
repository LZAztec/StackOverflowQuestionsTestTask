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

@property (nonatomic, strong) IBOutlet UIBarButtonItem *changeTagButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, strong) NSMutableArray *questions;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong) NSString *selectedTag;

- (IBAction) changeTagPressed:(id)sender;
- (void)refreshFirstPage;

@end

