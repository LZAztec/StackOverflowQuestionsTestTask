//
//  QuestionsTableViewController.m
//  StackOverflowQuestions
//
//  Created by Aztec on 07.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QuestionsTableViewController.h"
#import "QuestionProfileViewController.h"
#import "QuestionTableViewCell.h"
#import "UIViewController+MHSemiModal.h"
#import "NSString+HTML.h"

static NSString *const kErrorText = @"Cannot get the data. Please check your connection.";

@interface QuestionsTableViewController ()

- (void)queryDataForTag:(NSString *)tag;

@property (strong, readonly) NSDateFormatter *dateFormatter;

@end

@implementation QuestionsTableViewController

@synthesize questions;
@synthesize stackOverflowAPI;
@synthesize activityIndicatorView;

#pragma mark -
#pragma mark - Lifecycle

- (void)viewDidLoad
{
    self.stackOverflowAPI = [[StackOverflowAPI alloc] initWithDelegate:self];
    [self queryDataForTag: @"Objective-c"];

    tagPickerViewController = [[TagPickerViewController alloc]initWithNibName:@"TagPickerViewController" bundle:nil];
    tagPickerViewController.delegate = self;

    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showQuestionProfile"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        QuestionProfileViewController *destinationVC = segue.destinationViewController;

        destinationVC.question = questions[(NSUInteger) indexPath.row];
    }
}

#pragma mark -
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
    
    QuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[QuestionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    [cell setData:(NSDictionary *) (self.questions)[(NSUInteger) indexPath.row]];

    if ([cell.questionText.text isEqualToString:kErrorText]){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark -
#pragma mark - Stack Overflow API response handling methods

- (void)queryDataForTag:(NSString *)tag
{
    self.title = tag;
    [self showIndicator];

    [stackOverflowAPI getQuestionsByTags:@[tag]];
}

- (void)showIndicator
{
    questions = nil;
    [self.tableView reloadData];
    [activityIndicatorView startAnimating];
}

- (void)questionsResponseReturned:(NSDictionary *)response
{
    self.questions = [response valueForKey:@"items"];
    [activityIndicatorView stopAnimating];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Tag Picker View Controller Delegate methods
- (void) tagPickerDoneButtonPressed:(TagPickerViewController *)sender;
{
    NSInteger selectedRow = [sender.picker selectedRowInComponent:0];
    NSString *tag = (sender.pickerData)[(NSUInteger) selectedRow];

    [self queryDataForTag:tag];
    [self mh_dismissSemiModalViewController:sender animated:YES];
    [self toggleControlsToState:YES];
}

- (void) tagPickerCancelButtonPressed:(TagPickerViewController *)sender;
{
    [self mh_dismissSemiModalViewController:sender animated:YES];
    [self toggleControlsToState:YES];
}

#pragma -
#pragma Stack Overflow API Delegate methods
- (void)handleQuestionsByTagsResponse:(NSDictionary *)response
{
    [self questionsResponseReturned:response];
}

- (void)handleError:(NSError *)error
{
    NSLog(@"Error happened:%@", error);
    
    NSArray *errorCellData = @[@{
                                    @"title": kErrorText
                            }];
    self.questions = errorCellData;
    [activityIndicatorView stopAnimating];
    [self.tableView reloadData];
}

#pragma -
#pragma Change tag button methods

- (IBAction)changeTagPressed:(id)sender;
{
    [self toggleControlsToState:NO];
    [self mh_presentSemiModalViewController:tagPickerViewController animated:YES];
}


- (void)toggleControlsToState:(BOOL)state
{
    self.changeTagButton.enabled = state;
    self.tableView.scrollEnabled = state;
}

@end
