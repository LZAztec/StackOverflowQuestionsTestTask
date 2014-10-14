//
//  TagPickerViewController.h
//  StackOverflowQuestions
//
//  Created by Aztec on 13.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionsTableViewController.h"

@interface TagPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    UIPickerView *picker;
    NSArray *pickerData;
    QuestionsTableViewController *delegate;
}

@property (nonatomic, retain) IBOutlet UIPickerView *picker;
@property (nonatomic, retain) NSArray *pickerData;
@property (strong, nonatomic) QuestionsTableViewController *delegate;


- (IBAction)unwindToList:(UIStoryboardSegue *)segue;


@end