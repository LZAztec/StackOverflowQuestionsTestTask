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

@interface QuestionsTableViewController : UITableViewController <StackOverflowAPIDelegate, TagPickerViewControllerDelegate>{
    NSArray *questions;
    StackOverflowAPI *stackOverflowAPI;
    UIActivityIndicatorView *activityIndicatorView;
    TagPickerViewController *tagPickerViewController;
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *changeTagButton;
@property (strong, nonatomic) NSArray *questions;
@property (strong, nonatomic) StackOverflowAPI *stackOverflowAPI;

- (IBAction) changeTagPressed:(id)sender;

@end

