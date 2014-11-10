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

@interface QuestionListViewController : UITableViewController <TagPickerViewControllerDelegate, UIAlertViewDelegate>{
    NSMutableArray *questions;
    TagPickerViewController *tagPickerViewController;

    NSInteger _page;
    BOOL _hasMore;
    NSString *_selectedTag;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *changeTagButton;
@property (copy, nonatomic) NSMutableArray *questions;

- (IBAction) changeTagPressed:(id)sender;
- (void)refreshFirstPage;

@end

