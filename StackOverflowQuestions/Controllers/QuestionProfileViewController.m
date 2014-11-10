//
//  QuestionProfileViewController.m
//  StackOverflowQuestions
//
//  Created by Aztec on 08.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QuestionProfileViewController.h"
#import "QuestionProfileTableViewCell.h"
#import "VKontakteActivity.h"
#import "FormatHelper.h"

static const int kLoadingCellTag = 1273;
static const int kQuestionCellTag = 123123;
static const int kAnswerCellTag = 123124;

@interface QuestionProfileViewController ()

@property (weak, nonatomic) StackOverflowRequest *request;

- (IBAction)cellLongPressed:(UILongPressGestureRecognizer *)sender;

@end

@implementation QuestionProfileViewController

@synthesize question;
@synthesize tableData;

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableData = [[NSMutableArray alloc]init];
    self.title = question.title;

    _page = 0;
    _hasMore = YES;

    [self extractQuestionDataToFirstCell];
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

- (void)refreshFirstPage
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self queryAnswersForQuestionForce:YES];
}

- (void)clearPageData
{
    _page = 1;
    _hasMore = YES;
    [self.tableData removeAllObjects];
    [self extractQuestionDataToFirstCell];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)controlsEnabled:(BOOL)state
{
    self.tableView.scrollEnabled = state;
}

- (IBAction)cellLongPressed:(UILongPressGestureRecognizer *)sender;
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self showSharingControl];
    }
}

- (void)showSharingControl
{
    NSArray *items = @[self.question.title, self.question.link];
    VKontakteActivity *vkontakteActivity = [[VKontakteActivity alloc] initWithParent:self];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:items
                                                        applicationActivities:@[vkontakteActivity]];
    
    [self presentViewController:activityViewController animated:YES completion:nil];

}

#pragma mark - UI Table View Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_page == 0) {
        return 2;
    }

    if (_hasMore) {
        return self.tableData.count + 1;
    }
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionProfileTableViewCell *cell = nil;
    
    if (indexPath.row < self.tableData.count) {
        cell = [self questionProfileCellForIndexPath:indexPath];

        if (indexPath.row == 0) {
            cell.tag = kQuestionCellTag;
        } else {
            cell.tag = kAnswerCellTag;
        }
        
    } else {
        cell = [self loadingCellWithIndexPath:indexPath];
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.tag == kLoadingCellTag && _hasMore && !_request.isExecuting) {
        
        _page++;

        [self queryAnswersForQuestionForce:NO];
    }
}

- (QuestionProfileTableViewCell *)loadingCellWithIndexPath:(NSIndexPath *)indexPath
{
    QuestionProfileTableViewCell *cell = [[QuestionProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

    if (indexPath.row > 0){
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        activityIndicator.center = cell.center;
        [cell addSubview:activityIndicator];

        [activityIndicator startAnimating];
    }

    cell.tag = kLoadingCellTag;
    cell.authorName.hidden = YES;
    cell.modificationDate.hidden = YES;
    cell.score.hidden = YES;
    cell.QAText.hidden = YES;
    cell.isAnsweredImageView.hidden = YES;

    return cell;
}

- (QuestionProfileTableViewCell *)questionProfileCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"QACell";

    QuestionProfileTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (cell == nil) {
        cell = [[QuestionProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }

    [cell setCellData:(StackOverflowResponseModelItem *)tableData[(NSUInteger) indexPath.row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showSharingControl];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    // check here, if it is one of the cells, that needs to be resized
    // to the size of the contained UITextView
    if (indexPath.row > self.tableData.count){
        height = 146.0f;
    }else{
        height = [self textViewHeightForRowAtIndexPath:indexPath] + 81.0f;
    }
    NSLog(@"Height for row at index: %zd, %f", indexPath.row, height);
    return height;

}

- (CGFloat)textViewHeightForRowAtIndexPath: (NSIndexPath*)indexPath
{
    CGFloat height = 0;

    if (indexPath.row < [self.tableData count]) {
        StackOverflowResponseModelItem *data = (self.tableData)[(NSUInteger) indexPath.row];

        UITextView *calculationView = [[UITextView alloc] init];
        
        calculationView.attributedText = [FormatHelper formatText:data.body
                                       withCodeTagBackgroundColor:[UIColor brownColor]
                                                        textColor:[UIColor whiteColor]];
        
        // full screen width - image width (50) - paddings(8*3) (left + right + distance between image and text view)
        CGFloat textViewWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) - 50 - (8*3);
        CGSize size = [calculationView sizeThatFits:CGSizeMake(textViewWidth, FLT_MAX)];
        height = size.height + 10;
    }

    return height + 1;
}


#pragma mark - Stack Overflow data processing

- (void)queryAnswersForQuestionForce:(BOOL)force
{
    NSLog(@"Querying data for page: %ld, questionId: %@, hasMore: %@", (long)_page, question.id, (_hasMore) ? @"YES" : @"NO");

    if (_request == nil) {
        _request = [[StackOverflowAPINew questions] answersByQuestionIds:@[question.id]
                                                                    page:_page
                                                                   limit:10];
    }

    if (_request.isExecuting && force){
        [_request cancel];
    } else if (_request.isExecuting) {
        return;
    }

    [_request executeWithSuccessBlock:^(StackOverflowResponse *response) {
        NSLog(@"answers response: %@", response);
        for (StackOverflowResponseModelItem *data in response.parsedModel.items) {
            [self.tableData addObject:data];
        }
        _hasMore = [response.parsedModel.hasMore boolValue];

        if (force){
            [self clearPageData];
        }
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];

    } errorBlock:^(NSError *error) {
        [self handleError:error];
    }];
}

- (void)extractQuestionDataToFirstCell
{
    [self.tableData addObject:question];
}

#pragma -
#pragma Stack Overflow API Delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self controlsEnabled:YES];
    }
}

- (void)handleError:(NSError *)error
{
    NSLog(@"Error happened:%@", error);

    NSString *message = (error.domain != nil) ? error.domain : @"Unknown error! Please try again later!";
    [self controlsEnabled:NO];

    [[[UIAlertView alloc] initWithTitle:@"Oooops!"
                                message:message
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];

    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}
@end
