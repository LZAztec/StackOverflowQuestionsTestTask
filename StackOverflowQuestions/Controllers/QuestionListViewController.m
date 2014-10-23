//
//  QuestionListViewController.m
//  StackOverflowQuestions
//
//  Created by Aztec on 07.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QuestionListViewController.h"
#import "QuestionProfileViewController.h"
#import "QuestionListViewCell.h"
#import "QACellData.h"
#import "NSString+HTML.h"

static NSString *const kErrorText = @"Cannot get the data. Please check your connection and try later!";
const int kLoadingCellTag = 1273;

@interface QuestionListViewController ()

- (void)queryData;

@end

@implementation QuestionListViewController

@synthesize questions;
@synthesize stackOverflowAPI;
@synthesize activityIndicatorView;

#pragma mark -
#pragma mark - Lifecycle

- (void)viewDidLoad
{
    self.stackOverflowAPI = [[StackOverflowAPI alloc] initWithDelegate:self];

    _page = 0;
    _selectedTag = @"Objective-c";
    _hasMore = YES;
    self.title = _selectedTag;

    tagPickerViewController = [[TagPickerViewController alloc]initWithNibName:@"TagPickerViewController" bundle:nil];
    tagPickerViewController.delegate = self;
    questions = [[NSMutableArray alloc] init];

    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showQuestionProfile"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        QuestionProfileViewController *destinationVC = segue.destinationViewController;

        QACellData *data = questions[(NSUInteger) indexPath.row];
        NSLog(@"Question: %@", data);
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
    if (_page == 0) {
        return 1;
    }

    if (_hasMore) {
        return self.questions.count + 1;
    }
    return self.questions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.questions.count) {
        return [self questionCellForIndexPath:indexPath];
    } else {
        return [self loadingCell];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.tag == kLoadingCellTag && _hasMore) {

        _page++;

        [self queryData];
    }
}

- (QuestionListViewCell *)questionCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"QuestionCell";

    QuestionListViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];

    if (cell == nil) {
        cell = [[QuestionListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }

    [cell setCellData:(QACellData *)questions[(NSUInteger) indexPath.row]];

    if ([cell.questionText.text isEqualToString:kErrorText]){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}


- (UITableViewCell *)loadingCell
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    activityIndicator.center = cell.center;
    [cell addSubview:activityIndicator];

    [activityIndicator startAnimating];

    cell.tag = kLoadingCellTag;

    return cell;
}

#pragma mark -
#pragma mark - Stack Overflow API response handling methods

- (void)queryData
{
    NSLog(@"Querying data for page: %d, tag: %@, hasMore: %@", _page, _selectedTag, (_hasMore) ? @"YES" : @"NO");
    [stackOverflowAPI getQuestionsByTags:@[_selectedTag] page:@(_page) limit:@10];
}

- (void)clearTableDataAndResetAPIData
{
    _page = 1;
    _hasMore = YES;
    [questions removeAllObjects];
    [self.tableView reloadData];
}

- (void)questionsResponseReturned:(NSDictionary *)response
{
    NSArray *items = [response valueForKey:@"items"];

    for (NSDictionary *data in items) {
        QACellData *cellData = [[QACellData alloc] initWithAuthorName:[(NSString *) data[@"owner"][@"display_name"] stringByDecodingHTMLEntities]
                                                          counter:(NSNumber *) data[@"answer_count"]
                                                     creationDate:[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [data[@"creation_date"] doubleValue]]
                                                 lastModification:[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [data[@"last_edit_date"] doubleValue]]
                                                           status:(NSNumber *) data[@"is_answered"]
                                                             text:[(NSString *) data[@"title"] stringByDecodingHTMLEntities]
                                                               id:(NSString *) data[@"question_id"]
                                                             type:kCellDataQuestionType];
        if (![self.questions containsObject:cellData]) {
            [self.questions addObject:cellData];
        }
    }

    _hasMore = (BOOL)response[@"has_more"];
    [activityIndicatorView stopAnimating];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - Tag Picker View Controller Delegate methods
- (void) tagPickerDoneButtonPressed:(TagPickerViewController *)sender;
{
    NSInteger selectedRow = [sender.picker selectedRowInComponent:0];
    _selectedTag = (sender.pickerData)[(NSUInteger) selectedRow];

    self.title = _selectedTag;
    [self clearTableDataAndResetAPIData];

    [self queryData];
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
    
    [[[UIAlertView alloc] initWithTitle:@"Oooops!"
                                message:kErrorText
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
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
