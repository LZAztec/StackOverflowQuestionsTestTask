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

static NSString *const kErrorText = @"Cannot get the data. Please check your connection and try later!";
static const int kLoadingCellTag = 1273;

@interface QuestionListViewController ()

@property (weak, nonatomic) StackOverflowRequest *request;

- (void)queryDataForce:(BOOL)force;

@end

@implementation QuestionListViewController

@synthesize questions;

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _page = 0;
    _selectedTag = @"Objective-c";
    _hasMore = YES;
    self.title = _selectedTag;

    tagPickerViewController = [[TagPickerViewController alloc] initWithNibName:@"TagPickerViewController" bundle:nil];
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
    _page = 1;
    _hasMore = YES;
    [self queryDataForce:YES];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showQuestionProfile"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        QuestionProfileViewController *destinationVC = segue.destinationViewController;

        StackOverflowResponseModelItem *data = questions[(NSUInteger) indexPath.row];
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
    NSLog(@"ROW: %ld, questions count: %ld", (unsigned long)indexPath.row, (unsigned long)self.questions.count);
    if (indexPath.row < self.questions.count) {
        return [self questionCellForIndexPath:indexPath];
    } else {
        return [self loadingCellForIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.tag == kLoadingCellTag && _hasMore && !_request.isExecuting) {

        _page++;

        [self queryDataForce:NO];
    }
}

- (QuestionListViewCell *)questionCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reusableIdentifier = @"QuestionCell";
    QuestionListViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reusableIdentifier];

    if (cell == nil) {
        cell = [[QuestionListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableIdentifier];
    }

    [cell setCellData:questions[(NSUInteger) indexPath.row]];

    if ([cell.questionText.text isEqualToString:kErrorText]){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}


- (QuestionListViewCell *)loadingCellForIndexPath:(NSIndexPath *)indexPath
{
    QuestionListViewCell *cell = [[QuestionListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

    if (![self.refreshControl isRefreshing]){
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        activityIndicator.center = cell.center;
        [cell addSubview:activityIndicator];

        [activityIndicator startAnimating];
    }

    cell.tag = kLoadingCellTag;

    return cell;
}

#pragma mark - Stack Overflow API response handling methods

- (void)queryDataForce:(BOOL)force
{
    if (_request == nil){
        _request = [[StackOverflowAPI questions] questionsByTags:@[_selectedTag] page:_page limit:10];
    }

    if (_request.isExecuting && force){
        [_request cancel];
    } else if (_request.isExecuting) {
        return;
    }

    [_request executeWithSuccessBlock:^(StackOverflowResponse *response) {
        if (force) {
            [questions removeAllObjects];
        }

        for (StackOverflowResponseModelItem *data in response.parsedModel.items) {
            data.type = kCellDataQuestionType;
            [self.questions addObject:data];
        }
        _hasMore = [response.parsedModel.hasMore boolValue];

        [self.tableView reloadData];
        [self.refreshControl endRefreshing];

    } errorBlock:^(NSError *error) {
        [self handleError:error];
    }];
}

#pragma mark - Tag Picker View Controller Delegate methods
- (void) tagPickerDoneButtonPressed:(TagPickerViewController *)sender;
{
    NSInteger selectedRow = [sender.picker selectedRowInComponent:0];
    _selectedTag = (sender.pickerData)[(NSUInteger) selectedRow];

    self.title = _selectedTag;
    [questions removeAllObjects];
    [self.tableView reloadData];
    _page = 1;
    _hasMore = YES;

    [self queryDataForce:YES];
    [self mh_dismissSemiModalViewController:sender animated:YES];
    [self setControlsEnabled:YES];
}

- (void) tagPickerCancelButtonPressed:(TagPickerViewController *)sender;
{
    [self mh_dismissSemiModalViewController:sender animated:YES];
    [self setControlsEnabled:YES];
}

#pragma mark - Error handling
- (void)handleError:(NSError *)error
{
    NSLog(@"Error happened:%@", error);

    NSString *message = (error.domain != nil) ? error.domain : kErrorText;
    [self setControlsEnabled:NO];
    
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
        [self setControlsEnabled:YES];
    }
}

#pragma -
#pragma Change tag button methods

- (IBAction)changeTagPressed:(id)sender;
{
    [self setControlsEnabled:NO];
    [self mh_presentSemiModalViewController:tagPickerViewController animated:YES];
}


- (void)setControlsEnabled:(BOOL)state
{
    self.changeTagButton.enabled = state;
    self.tableView.scrollEnabled = state;
}

@end
