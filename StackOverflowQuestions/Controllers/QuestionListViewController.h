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

@interface QuestionListViewController : UITableViewController <StackOverflowAPIDelegate, TagPickerViewControllerDelegate>{
    NSMutableArray *questions;
    StackOverflowAPI *stackOverflowAPI;
    UIActivityIndicatorView *activityIndicatorView;
    TagPickerViewController *tagPickerViewController;

    NSInteger _page;
    BOOL _hasMore;
    NSString *_selectedTag;
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *changeTagButton;
@property (copy, nonatomic) NSMutableArray *questions;
@property (strong, nonatomic) StackOverflowAPI *stackOverflowAPI;

- (IBAction) changeTagPressed:(id)sender;

@end

