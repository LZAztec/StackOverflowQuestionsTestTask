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
static const int kQuestionCellTag = 123123;
static const int kAnswerCellTag = 123124;

@interface QuestionProfileViewController ()

- (IBAction)cellLongPressed:(UILongPressGestureRecognizer *)sender;

@property (strong, nonatomic) NSMutableDictionary *textViews;

@end

@implementation QuestionProfileViewController

@synthesize question;
@synthesize tableData;
@synthesize stackOverflowAPI;

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableData = [[NSMutableArray alloc]init];
    self.title = question.title;
    self.stackOverflowAPI = [[StackOverflowAPI alloc] initWithDelegate:self];
    self.textViews = [[NSMutableDictionary alloc] init];

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
    NSLog(@"\n%@ %zd", NSStringFromSelector(_cmd), indexPath.row);
    
    static NSString *reuseIdentifier = @"QACell";

    QuestionProfileTableViewCell *cell = nil;
    
    if (indexPath.row < self.tableData.count) {
        cell = [self questionProfileCellForIndexPath:indexPath reuseIdentifier:reuseIdentifier];

        if (indexPath.row == 0) {
            cell.tag = kQuestionCellTag;
        } else {
            cell.tag = kAnswerCellTag;
        }
        
    } else {
        cell = [self loadingCellWithReuseIdentifier:reuseIdentifier];
    }

    (self.textViews)[indexPath] = cell.QAText;

    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.tag == kLoadingCellTag && _hasMore) {

        _page++;

        [self queryAnswersForQuestion];
    }
}

- (QuestionProfileTableViewCell *)loadingCellWithReuseIdentifier:(NSString *)reuseIdentifier
{
    QuestionProfileTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (cell == nil) {
        cell = [[QuestionProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    activityIndicator.center = cell.center;
    [cell addSubview:activityIndicator];

    [activityIndicator startAnimating];

    cell.tag = kLoadingCellTag;

    cell.authorName.hidden = YES;
    cell.modificationDate.hidden = YES;
    cell.score.hidden = YES;
    cell.QAText.hidden = YES;
    cell.isAnsweredImageView.hidden = YES;

    return cell;
}

- (QuestionProfileTableViewCell *)questionProfileCellForIndexPath:(NSIndexPath *)indexPath reuseIdentifier:(NSString *)reuseIdentifier
{

    QuestionProfileTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (cell == nil) {
        cell = [[QuestionProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }

    [cell setCellData:(StackOverflowResponseData *)tableData[(NSUInteger) indexPath.row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showSharingControl];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // check here, if it is one of the cells, that needs to be resized
    // to the size of the contained UITextView


    CGFloat height = [self textViewHeightForRowAtIndexPath:indexPath] + 81.0f;
    return height;
}

- (CGFloat)textViewHeightForRowAtIndexPath: (NSIndexPath*)indexPath
{
    UITextView *calculationView = (self.textViews)[indexPath];
    // full screen width - image width (50) - paddings(8*3) (left + right + distance between image and text view)
    CGFloat textViewWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) - 50 - (8*3);
    NSLog(@"Width of calculation view: %f, %@", textViewWidth, NSStringFromCGRect(calculationView.frame));
    CGSize size = [calculationView sizeThatFits:CGSizeMake(textViewWidth, FLT_MAX)];
    return size.height;
}


#pragma mark - Stack Overflow data processing
- (void)queryAnswersForQuestion
{
    self.stackOverflowAPI.simulateQueries = [[UserSettings sharedInstance] simulateQueriesState];
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

    StackOverflowResponseData *cellData = [[StackOverflowResponseData alloc] init];
    cellData.authorName = name;
    cellData.counter = count;
    cellData.creationDate = creationDate;
    cellData.lastModificationDate = date;
    cellData.status = status;
    cellData.body = text;
    cellData.id = id;
    cellData.type = kCellDataAnswerType;

    if (![self.tableData containsObject:cellData] ) {
        [self.tableData addObject:cellData];
    }
}

- (void)extractQuestionDataToFirstCell
{
    if (![self.tableData containsObject:question] ){
        [self.tableData addObject:question];
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
