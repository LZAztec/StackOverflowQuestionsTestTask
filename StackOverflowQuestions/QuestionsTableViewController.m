//
//  ViewController.m
//  StackOverflowQuestions
//
//  Created by Aztec on 07.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QuestionsTableViewController.h"
#import "StackOverflowAPI.h"
#import "QuestionProfileViewController.h"
#import "CustomTableViewCell.h"
#import <objc/message.h>

@interface QuestionsTableViewController ()

- (void)queryDataForTag:(NSString *)tag;

@end

@implementation QuestionsTableViewController

@synthesize pickerData;
@synthesize picker;
@synthesize changeTagBtn;
@synthesize questions;
@synthesize stackOverflowAPI;

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    pickerData = @[@"iOS", @"xcode", @"Objective-c", @"cocoa-touch", @"iPhone"];

    picker.hidden = YES;
    
    NSInteger defaultSelectedRowIndex = 2;
    NSString *tagTitle = [pickerData objectAtIndex:defaultSelectedRowIndex];
    
    self.title = tagTitle;
    self.stackOverflowAPI = [[StackOverflowAPI alloc] init];

    [self queryDataForTag: tagTitle];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)queryDataForTag:(NSString *)tag
{
    [stackOverflowAPI getQuestionsByTags:@[tag] withResponseHandler:self andSelector:@selector(questionsResponseReturned:)];
}

- (IBAction)changeTagPressed:(id)sender
{
    if (picker.hidden) {
        picker.hidden = NO;
    } else {
        picker.hidden = YES;
        NSInteger selectedRow = [picker selectedRowInComponent:0];
        NSString *tag = [pickerData objectAtIndex:selectedRow];
        [self queryDataForTag:tag];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showQuestionProfile"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        QuestionProfileViewController *destinationVC = segue.destinationViewController;

        destinationVC.question = [questions objectAtIndex:indexPath.row];
        destinationVC.stackOverflowAPI = self.stackOverflowAPI;
    }
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
    return [pickerData objectAtIndex:row];
}

#pragma mark - UI Table View Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [questions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"QuestionCell";
    
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
  
    NSDictionary *question = (NSDictionary *)[self.questions objectAtIndex:indexPath.row];

    if (question) {
        cell.authorName.text = [NSString stringWithFormat:@"Author: %@", (NSString *) question[@"owner"][@"display_name"]];

        NSNumber *answerCount = (NSNumber *) question[@"answer_count"];
        cell.answerCount.text = [NSString stringWithFormat:@"Answers: %@", [NSString stringWithFormat:@"%@", answerCount]];

        NSDate *modificationDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [[question objectForKey:@"last_edit_date"] doubleValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        cell.modificationDate.text = [dateFormatter stringFromDate:modificationDate];

        cell.questionText.text = question[@"title"];
    }
    
    return cell;
}

#pragma mark - Stack Overflow API response handling methods

- (void)questionsResponseReturned:(NSDictionary *)response
{
    self.questions = [response valueForKey:@"items"];
    [self.tableView reloadData];
}


@end
