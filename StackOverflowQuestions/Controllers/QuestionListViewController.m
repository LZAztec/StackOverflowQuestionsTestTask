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
#import "StackOverflowConstants.h"

static NSString *const kErrorText = @"Cannot get the data. Please check your connection and try later!";
static const int kLoadingCellTag = 1273;

@interface QuestionListViewController ()

@property (nonatomic, strong) StackOverflowRequest *request;
@property (nonatomic, strong) TagPickerViewController *tagPickerViewController;
@property (nonatomic, assign) UIDeviceOrientation previousOrientation;

- (void)queryDataForce:(BOOL)force;

@end

@implementation QuestionListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.page = 0;
    self.selectedTag = @"Objective-c";
    self.hasMore = YES;
    self.title = self.selectedTag;

    self.tagPickerViewController = [[TagPickerViewController alloc] initWithNibName:@"TagPickerViewController" bundle:nil];
    self.tagPickerViewController.delegate = self;
    self.questions = [[NSMutableArray alloc] init];

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
    self.page = 1;
    self.hasMore = YES;
    [self queryDataForce:YES];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showQuestionProfile"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        QuestionProfileViewController *destinationVC = segue.destinationViewController;

        StackOverflowResponseBaseModelItem *data = self.questions[(NSUInteger) indexPath.row];
        NSLog(@"Question: %@", data);
        destinationVC.question = self.questions[(NSUInteger) indexPath.row];
    }
}

#pragma mark - UI Table View Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.page == 0) {
        return 1;
    }

    if (self.hasMore) {
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
        return [self loadingCellForIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.tag == kLoadingCellTag && self.hasMore && !self.request.isExecuting) {
        self.page++;
        NSLog(@"Page: %lu", (unsigned long)self.page);
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

    [cell setCellData:self.questions[(NSUInteger) indexPath.row]];

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
    if (force && self.request.isExecuting){
        [self.request cancel];
    }

    StackOverflowRequest *request = [[StackOverflowAPI questions] questionsByTags:@[self.selectedTag]];

    [request addExtraParameters:@{
            kStackOverflowAPIDataPerPageKey : @10,
            kStackOverflowAPIPageKey : @(self.page)}
    ];

    QuestionListViewController *__weak controller = self;

    [request executeWithSuccessBlock:^(StackOverflowResponse *response) {
        NSLog(@"Response model: %@", response.parsedModel);
        if (force) {
            [controller.questions removeAllObjects];
        }

        for (StackOverflowResponseBaseModelItem *data in response.parsedModel.items) {
            data.type = kCellDataQuestionType;
            [controller.questions addObject:data];
        }
        controller.hasMore = [response.parsedModel.hasMore boolValue];

        [controller.tableView reloadData];
        [controller.refreshControl endRefreshing];

    } errorBlock:^(NSError *error) {
        if (error.domain == NSStringFromClass(StackOverflowRequest.class) && error.code == StackOverflowErrorRequestCancelled) {
            NSLog(@"%@", error);
        } else {
            [controller handleError:error];
        }

    }];

    self.request = request;
}

#pragma mark - Tag Picker View Controller Delegate methods
- (void) tagPickerDoneButtonPressed:(TagPickerViewController *)sender;
{
    NSInteger selectedRow = [sender.picker selectedRowInComponent:0];
    self.selectedTag = (sender.pickerData)[(NSUInteger) selectedRow];

    self.title = self.selectedTag;
    [self.questions removeAllObjects];
    [self.tableView reloadData];
    self.page = 1;
    self.hasMore = YES;

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
    [self mh_presentSemiModalViewController:self.tagPickerViewController animated:YES];
}


- (void)setControlsEnabled:(BOOL)state
{
    self.changeTagButton.enabled = state;
    self.settingsButton.enabled = state;
    self.tableView.scrollEnabled = state;
}

@end
