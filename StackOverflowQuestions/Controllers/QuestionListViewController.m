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
#import "NSString+HTML.h"

static NSString *const kErrorText = @"Cannot get the data. Please check your connection and try later!";
static const int kLoadingCellTag = 1273;

@interface QuestionListViewController ()

@property BOOL processingQuery;

- (void)queryData;

@end

@implementation QuestionListViewController

@synthesize questions;
@synthesize stackOverflowAPI;

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.stackOverflowAPI = [[StackOverflowAPI alloc] initWithDelegate:self];

    _page = 0;
    _selectedTag = @"Objective-c";
    _hasMore = YES;
    self.title = _selectedTag;

    tagPickerViewController = [[TagPickerViewController alloc]initWithNibName:@"TagPickerViewController" bundle:nil];
    tagPickerViewController.delegate = self;
    questions = [[NSMutableArray alloc] init];

    [self addRefreshControl];
}

- (void)addRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc]init];

    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self
                            action:@selector(refreshFirstPage)
                  forControlEvents:UIControlEventValueChanged];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshFirstPage
{
    [self clearTableDataAndResetAPIData];
    [self queryData];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showQuestionProfile"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        QuestionProfileViewController *destinationVC = segue.destinationViewController;

        StackOverflowResponseData *data = questions[(NSUInteger) indexPath.row];
        NSLog(@"Question: %@", data);
        destinationVC.question = questions[(NSUInteger) indexPath.row];
    }
}

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
    if (cell.tag == kLoadingCellTag && _hasMore && !_processingQuery) {

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

    [cell setCellData:(StackOverflowResponseData *)questions[(NSUInteger) indexPath.row]];

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

#pragma mark - Stack Overflow API response handling methods

- (void)queryData
{
    _processingQuery = YES;
    NSLog(@"Querying data for page: %ld, tag: %@, hasMore: %@", (long)_page, _selectedTag, (_hasMore) ? @"YES" : @"NO");
    [stackOverflowAPI getQuestionsByTags:@[_selectedTag] page:@(_page) limit:@10];
}

- (void)clearTableDataAndResetAPIData
{
    _page = 1;
    _hasMore = YES;
    [questions removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - Tag Picker View Controller Delegate methods
- (void) tagPickerDoneButtonPressed:(TagPickerViewController *)sender;
{
    NSInteger selectedRow = [sender.picker selectedRowInComponent:0];
    _selectedTag = (sender.pickerData)[(NSUInteger) selectedRow];

    self.title = _selectedTag;
    [self clearTableDataAndResetAPIData];

    [self queryData];
    [self mh_dismissSemiModalViewController:sender animated:YES];
    [self controlsEnabled:YES];
}

- (void) tagPickerCancelButtonPressed:(TagPickerViewController *)sender;
{
    [self mh_dismissSemiModalViewController:sender animated:YES];
    [self controlsEnabled:YES];
}

#pragma -
#pragma Stack Overflow API Delegate methods
- (void)handleQuestionsByTagsResponse:(NSDictionary *)response
{
    NSArray *items = [response valueForKey:@"items"];

    for (NSDictionary *data in items) {
        StackOverflowResponseData *cellData = [[StackOverflowResponseData alloc] init];
        cellData.authorName = [(NSString *) data[@"owner"][@"display_name"] stringByDecodingHTMLEntities];
        cellData.counter = (NSNumber *) data[@"answer_count"];
        cellData.creationDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [data[@"creation_date"] doubleValue]];
        cellData.lastModificationDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [data[@"last_edit_date"] doubleValue]];
        cellData.status = (NSNumber *) data[@"is_answered"];
        cellData.title = [(NSString *) data[@"title"] stringByDecodingHTMLEntities];
        cellData.body = [(NSString *) data[@"body"] stringByDecodingHTMLEntities];
        cellData.id = (NSString *) data[@"question_id"];
        cellData.type = kCellDataQuestionType;
        cellData.link = [NSURL URLWithString:data[@"link"]];

        if (![self.questions containsObject:cellData]) {
            [self.questions addObject:cellData];
        }
    }
    NSLog(@"questions: %@", self.questions);
    _hasMore = [(NSNumber *)response[@"has_more"] isEqualToNumber:@1];

    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    _processingQuery = NO;
}

#pragma mark - Error handling
- (void)handleError:(NSError *)error
{
    NSLog(@"Error happened:%@", error);

    NSString *message = (error.domain != nil) ? error.domain : kErrorText;
    [self controlsEnabled:NO];
    
    [[[UIAlertView alloc] initWithTitle:@"Oooops!"
                                message:message
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];

    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self controlsEnabled:YES];
    }
}

#pragma -
#pragma Change tag button methods

- (IBAction)changeTagPressed:(id)sender;
{
    [self controlsEnabled:NO];
    [self mh_presentSemiModalViewController:tagPickerViewController animated:YES];
}


- (void)controlsEnabled:(BOOL)state
{
    self.changeTagButton.enabled = state;
    self.tableView.scrollEnabled = state;
}

@end
