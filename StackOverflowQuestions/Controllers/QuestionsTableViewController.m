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
#import "QuestionTableViewCell.h"
#import "TagPickerViewController.h"


@interface QuestionsTableViewController ()

- (void)queryDataForTag:(NSString *)tag;

@end

@implementation QuestionsTableViewController

@synthesize questions;
@synthesize stackOverflowAPI;
@synthesize activityIndicatorView;

#pragma mark -
#pragma mark - Lifecycle

- (void)viewDidLoad
{
    self.stackOverflowAPI = [[StackOverflowAPI alloc] init];
    [self queryDataForTag: @"Objective-c"];
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

        destinationVC.question = [questions objectAtIndex:indexPath.row];
        destinationVC.stackOverflowAPI = self.stackOverflowAPI;
    } else if ([segue.identifier isEqualToString:@"chooseTagModal"]) {
        
        TagPickerViewController *destinationVC = segue.destinationViewController;
        
        destinationVC.delegate = self;
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
  
    NSDictionary *question = (NSDictionary *)[self.questions objectAtIndex:indexPath.row];

    if (question) {
        cell.authorName.text = [NSString stringWithFormat:@"%@", (NSString *) question[@"owner"][@"display_name"]];

        NSNumber *answerCount = (NSNumber *) question[@"answer_count"];
        cell.answerCount.text = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@", answerCount]];

        NSDate *modificationDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [[question objectForKey:@"last_edit_date"] doubleValue]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        cell.modificationDate.text = [dateFormatter stringFromDate:modificationDate];

        cell.questionText.text = question[@"title"];
    }
    
    return cell;
}

#pragma mark -
#pragma mark - Stack Overflow API response handling methods

- (void)queryDataForTag:(NSString *)tag
{
    self.title = tag;
    [self showIndicator];

    [stackOverflowAPI getQuestionsByTags:@[tag]
                     withResponseHandler:self
                             andSelector:@selector(questionsResponseReturned:)];
}

- (void)showIndicator
{
    questions = nil;
    [self.tableView reloadData];
    activityIndicatorView.hidden = NO;
}

- (void)questionsResponseReturned:(NSDictionary *)response
{
    self.questions = [response valueForKey:@"items"];
    activityIndicatorView.hidden = YES;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Tag Change Actions
- (void)tagSelected:(NSString *)tagName;
{
    [self queryDataForTag:tagName];
}


@end
