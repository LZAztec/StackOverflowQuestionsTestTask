//
//  TagPickerViewController.h
//  StackOverflowQuestions
//
//  Created by Aztec on 13.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MHSemiModal.h"

@protocol TagPickerViewControllerDelegate;

@interface TagPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    UIPickerView *picker;
    NSArray *pickerData;
}

@property (nonatomic, retain) IBOutlet UIPickerView *picker;
@property (nonatomic, retain) NSArray *pickerData;
@property (weak) id<TagPickerViewControllerDelegate> delegate;


- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end

@protocol TagPickerViewControllerDelegate <NSObject>

- (void) tagPickerDoneButtonPressed:(TagPickerViewController *)sender;
- (void) tagPickerCancelButtonPressed:(TagPickerViewController *)sender;

@end
