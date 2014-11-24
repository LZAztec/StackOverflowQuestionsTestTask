//
//  QuestionProfileViewController.m
//  StackOverflowQuestions
//
//  Created by Aztec on 08.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Social/Social.h>
#import "QuestionProfileViewController.h"
#import "QuestionProfileTableViewCell.h"
#import "FormatHelper.h"
#import "NSString+HTML.h"

typedef NS_ENUM(NSInteger, StackOverflowQuestionsSharingType) {
    StackOverflowQuestionsSharingTypeFacebook = 0,
    StackOverflowQuestionsSharingTypeTwitter,
    StackOverflowQuestionsSharingTypeVKontakte
};

static const int kLoadingCellTag = 1273;
static const int kQuestionCellTag = 123123;
static const int kAnswerCellTag = 123124;

@interface QuestionProfileViewController ()

@property (nonatomic, strong) StackOverflowRequest *request;
@property (nonatomic, strong) NSMutableDictionary *sharingControllers;
@property (nonatomic, assign) UIDeviceOrientation previousOrientation;

- (IBAction)cellLongPressed:(UILongPressGestureRecognizer *)sender;

@end

@implementation QuestionProfileViewController

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableData = [[NSMutableArray alloc]init];
    self.title = [self.question.title stringByDecodingHTMLEntities];

    self.page = 0;
    self.hasMore = YES;

    self.sharingControllers = [@{
            @(StackOverflowQuestionsSharingTypeFacebook) : [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook],
            @(StackOverflowQuestionsSharingTypeTwitter) : [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter],
            @(StackOverflowQuestionsSharingTypeVKontakte) : [[VKontakteActivity alloc] initWithParent:self]
    } mutableCopy];

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
    self.page = 1;
    self.hasMore = 1;
    [self queryAnswersForQuestionForce:YES];
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
    if ([[UserSettings sharedInstance] useUIActivityControllerForSharing]){
        NSArray *items = @[self.question.title, self.question.link];
        VKontakteActivity *vkontakteActivity = [[VKontakteActivity alloc] initWithParent:self];

        UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                initWithActivityItems:items
                applicationActivities:@[vkontakteActivity]];

        NSMutableArray *excludedActivityTypes = [@[
                UIActivityTypeMail,
                UIActivityTypeCopyToPasteboard,
        ] mutableCopy];

        // if current os version greater than 7.0, exclude "AddToReadingList" option
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
            [excludedActivityTypes addObject:UIActivityTypeAddToReadingList];
        }

        activityViewController.excludedActivityTypes = excludedActivityTypes;

        [self presentViewController:activityViewController animated:YES completion:nil];
    } else {
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share via..."
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Facebook", @"Twitter", @"VK", nil];

        [actionSheet showInView:self.view];
    }


}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    UIDeviceOrientation currentOrientation = device.orientation;
    ////
    UIView *coverView = [self.view viewWithTag:kCoverViewTag];
    CGRect coverBounds = coverView.bounds;

    if (UIDeviceOrientationIsLandscape(currentOrientation) &&
            !(UIDeviceOrientationIsLandscape(self.previousOrientation) || self.previousOrientation == UIDeviceOrientationPortraitUpsideDown)) {

        coverBounds.origin.y += coverBounds.origin.y;

        coverView.bounds = coverBounds;
        coverView.frame = coverBounds;
    }

    self.previousOrientation = currentOrientation;
}

#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == StackOverflowQuestionsSharingTypeFacebook) {
        // share in Facebook
        SLComposeViewController *controller = self.sharingControllers[@(buttonIndex)];

        [controller setInitialText:[self.question.title stringByDecodingHTMLEntities]];
        [controller addURL:self.question.link];

        [self presentViewController:controller animated:YES completion:nil];

    } else if (buttonIndex == StackOverflowQuestionsSharingTypeTwitter) {
        // share in Twitter
        SLComposeViewController *tweetSheet = self.sharingControllers[@(buttonIndex)];

        [tweetSheet setInitialText:[self.question.title stringByDecodingHTMLEntities]];
        [tweetSheet addURL:self.question.link];

        [self presentViewController:tweetSheet animated:YES completion:nil];

    } else if (buttonIndex == StackOverflowQuestionsSharingTypeVKontakte) {
        // share in VK
        NSArray *items = @[self.question.title, self.question.link];

        VKontakteActivity *vkontakteActivity = self.sharingControllers[@(buttonIndex)];
        [vkontakteActivity resetActivityData];

        if ([vkontakteActivity canPerformWithActivityItems:items]){

            [vkontakteActivity prepareWithActivityItems:items];
            [vkontakteActivity performActivity];
        }
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
        return 2;
    }

    if (self.hasMore) {
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
    if (cell.tag == kLoadingCellTag && self.hasMore && !self.request.isExecuting) {
        
        self.page++;

        [self queryAnswersForQuestionForce:NO];
    }
}

- (QuestionProfileTableViewCell *)loadingCellWithIndexPath:(NSIndexPath *)indexPath
{
    QuestionProfileTableViewCell *cell = [[QuestionProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

    if ([self.refreshControl isRefreshing]) {
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

    [cell setCellData:(StackOverflowResponseBaseModelItem *)self.tableData[indexPath.row]];

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
        StackOverflowResponseBaseModelItem *data = (self.tableData)[(NSUInteger) indexPath.row];

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
    if (force && self.request.isExecuting){
        [self.request cancel];
    }

    NSLog(@"Querying data for page: %ld, questionId: %@, hasMore: %@", (long)self.page, self.question.dataId, (self.hasMore) ? @"YES" : @"NO");

    StackOverflowRequest *request = [[StackOverflowAPI questions] answersByQuestionIds:@[self.question.dataId]];

    [request addExtraParameters:@{
            kStackOverflowAPIDataPerPageKey : @10,
            kStackOverflowAPIPageKey : @(self.page)}
    ];

    __weak QuestionProfileViewController *controller = self;

    [request executeWithSuccessBlock:^(StackOverflowResponse *response) {
        NSLog(@"answers response: %@", response);
        if (force){
            [controller.tableData removeAllObjects];
            [controller extractQuestionDataToFirstCell];
        }

        for (StackOverflowResponseBaseModelItem *data in response.parsedModel.items) {
            data.type = kCellDataAnswerType;
            [controller.tableData addObject:data];
        }
        self.hasMore = [response.parsedModel.hasMore boolValue];

        [controller.tableView reloadData];
        [controller.refreshControl endRefreshing];

    } errorBlock:^(NSError *error) {
        if (error.domain == NSStringFromClass(StackOverflowRequest.class) && error.code == kStackOverflowRequestErrorCancelled) {
            NSLog(@"%@", error);
        } else {
            [controller handleError:error];
        }
    }];

    self.request = request;
}

- (void)extractQuestionDataToFirstCell
{
    [self.tableData addObject:self.question];
}

#pragma mark - Stack Overflow API Delegate methods

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

#pragma mark -

- (void)enableUserInteraction:(BOOL)state
{
    self.navigationItem.hidesBackButton = !state;
    self.tableView.scrollEnabled = state;
}

- (void)showModalController:(UIViewController *)controller {
    [self mh_presentSemiModalViewController:controller animated:YES];
}


@end
