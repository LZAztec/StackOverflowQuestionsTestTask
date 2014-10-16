//
//  TagPickerViewController.m
//  StackOverflowQuestions
//
//  Created by Aztec on 13.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "TagPickerViewController.h"

@interface TagPickerViewController ()

@end

@implementation TagPickerViewController

@synthesize pickerData;
@synthesize picker;

- (void)viewDidLoad
{
    pickerData = @[@"iOS", @"xcode", @"Objective-c", @"cocoa-touch", @"iPhone"];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerData count];
}

#pragma mark - Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return pickerData[(NSUInteger) row];
}

#pragma mark - 
#pragma mark - Navigation
- (IBAction)unwindToList:(UIStoryboardSegue *)segue
{
    NSInteger selectedRow = [self.picker selectedRowInComponent:0];
    NSString *tag = (self.pickerData)[(NSUInteger) selectedRow];
    
    [self.delegate tagSelected:tag];

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
