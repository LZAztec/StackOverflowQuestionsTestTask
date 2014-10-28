//
//  QuestionProfileViewController.m
//  StackOverflowQuestions
//
//  Created by Aztec on 08.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QuestionProfileViewController.h"
#import "QuestionProfileTableViewCell.h"
#import "NSString+HTML.h"
#import "UserSettings.h"
#import "VKontakteActivity.h"

static const int kLoadingCellTag = 1273;

@interface QuestionProfileViewController ()

- (IBAction)cellLongPressed:(UILongPressGestureRecognizer *)sender;

@end

@implementation QuestionProfileViewController

@synthesize question;
@synthesize tableData;
@synthesize stackOverflowAPI;

#pragma mark -
#pragma mark Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableData = [[NSMutableArray alloc]init];
    self.title = question.text;


    self.stackOverflowAPI = [[StackOverflowAPI alloc] initWithDelegate:self];

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
    [self clearFirstPageData];
    [self queryAnswersForQuestion];
}

- (void)clearFirstPageData
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
    NSArray *items = @[self.question.text, self.question.link];
    VKontakteActivity *vkontakteActivity = [[VKontakteActivity alloc] initWithParent:self];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:items
                                                        applicationActivities:@[vkontakteActivity]];
    
    [self presentViewController:activityViewController animated:YES completion:nil];

}

#pragma mark -
#pragma mark UI Table View Methods
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
    if (indexPath.row < self.tableData.count) {
        return [self questionProfileCellForIndexPath:indexPath];
    } else {
        return [self loadingCell];
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.tag == kLoadingCellTag && _hasMore) {

        _page++;

        [self queryAnswersForQuestion];
    }
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

- (UITableViewCell *)questionProfileCellForIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"QACell";

    QuestionProfileTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];

    if (cell == nil) {
        cell = [[QuestionProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }

    [cell setCellData:(QACellData *)tableData[(NSUInteger) indexPath.row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showSharingControl];
}

#pragma mark -
#pragma mark Stack Overflow data processing
- (void)queryAnswersForQuestion
{
    self.stackOverflowAPI.simulateQueries = [[UserSettings sharedInstance] getSimulateQueriesState];
    NSLog(@"Querying data for page: %ld, questionId: %@, hasMore: %@", (long)_page, question.id, (_hasMore) ? @"YES" : @"NO");
    [stackOverflowAPI getAnswersByQuestionIds:@[question.id] page:@(_page) limit:@50];
}

- (void)addCellDataWithAuthorName:(NSString *)name
                            score:(NSNumber *)count
                     lastEditDate:(NSDate *)date
                           QAText:(NSString *)text
                           status:(NSNumber *)status
                               id:(NSString *)id
                     creationDate:(NSDate *)creationDate
{
    if (date == nil) {
        date = [[NSDate alloc]initWithTimeIntervalSinceNow:0];
    }

    QACellData *cellData = [[QACellData alloc] initWithAuthorName:name
                                                          counter:count
                                                     creationDate:creationDate
                                                 lastModification:date
                                                           status:status
                                                             text:[text stringByDecodingHTMLEntities]
                                                               id:id
                                                             type:kCellDataAnswerType
                                                             link:nil];

    if (![self.tableData containsObject:cellData] ) {
        [self.tableData addObject:cellData];
    }
}

- (void)extractQuestionDataToFirstCell
{
    if (![self.tableData containsObject:question] ){
        [self.tableData addObject:question];
        [self.tableView reloadData];
    }
}

#pragma -
#pragma Stack Overflow API Delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self controlsEnabled:YES];
    }
}

- (void)handleAnswersByQuestionIdsResponse:(NSDictionary *)response
{
    NSArray *items = response[@"items"];
    for (id answer in items){
        NSDate *modificationDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [[answer objectForKey:@"last_activity_date"] doubleValue]];
        NSDate *creationDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [[answer objectForKey:@"creation_date"] doubleValue]];

        [self addCellDataWithAuthorName:answer[@"owner"][@"display_name"]
                                  score:(NSNumber *) answer[@"score"]
                           lastEditDate:modificationDate
                                 QAText:answer[@"body"]
                                 status:(NSNumber *) answer[@"is_accepted"]
                                     id:answer[@"answer_id"]
                           creationDate:creationDate];
    }

    _hasMore = [(NSNumber *)response[@"has_more"] isEqualToNumber:@1];

    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)handleError:(NSError *)error
{
    NSLog(@"Error happened:%@", error);
    _hasMore = NO;

    NSString *message = (error.domain != nil) ? error.domain : @"Unknon error! Please try again later!";
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
