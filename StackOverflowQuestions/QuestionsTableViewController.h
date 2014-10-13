//
//  ViewController.h
//  StackOverflowQuestions
//
//  Created by Aztec on 07.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StackOverflowAPI.h"

@interface QuestionsTableViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource>{
    UIPickerView *picker;
    NSArray *pickerData;
    UIBarButtonItem *changeTagBtn;
    NSArray *questions;
    StackOverflowAPI *stackOverflowAPI;
}

@property (nonatomic, retain) IBOutlet UIPickerView *picker;
@property (nonatomic, retain) NSArray *pickerData;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *changeTagBtn;
@property (strong, nonatomic) NSArray *questions;
@property (strong, nonatomic) StackOverflowAPI *stackOverflowAPI;

- (IBAction)changeTagPressed:(id)sender;

@end

