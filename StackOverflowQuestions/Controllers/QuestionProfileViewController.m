//
//  QuestionProfileViewController.m
//  StackOverflowQuestions
//
//  Created by Aztec on 08.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QuestionProfileViewController.h"
#import "StackOverflowAPI.h"
#import "QATableViewCell.h"
#import "NSString+StripHtml.h"

@interface QuestionProfileViewController ()

@end

@implementation QuestionProfileViewController

@synthesize question;
@synthesize tableData;
@synthesize stackOverflowAPI;
@synthesize dateFormatter;


#pragma mark - Lifecycle
- (void)viewDidLoad {
    
    self.tableData = [[NSMutableArray alloc]init];
    
    self.title = [question valueForKey:@"title"];

    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    [self extractQuestionDataToFirstCell];
    [self queryAnswersForQuestion];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)extractQuestionDataToFirstCell
{
    
    NSNumber *answerCount = (NSNumber *) question[@"answer_count"];
    
    NSDate *modificationDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [[question objectForKey:@"last_edit_date"] doubleValue]];
    
    [self addCellDataWithOwnerName:(NSString *) question[@"owner"][@"display_name"]
                             score:answerCount
                      lastEditDate:modificationDate
                            QAText:question[@"title"]
                        status:@0];
    
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */


#pragma mark - UI Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"QACell";
    
    QATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[QATableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSDictionary *cellData = (NSDictionary *)[tableData objectAtIndex:indexPath.row];
    
    if (cellData) {
        cell.authorName.text = cellData[@"owner_name"];
        cell.score.text = cellData[@"answer_count"];
        cell.modificationDate.text = cellData[@"last_edit_date"];
        cell.QAText.text = cellData[@"qa_text"];
        cell.isAnsweredImageView.hidden = [(NSNumber *)cellData[@"status"] isEqualToNumber:@0];
    }
    
    if (indexPath.row == 0){
        cell.viewForBaselineLayout.backgroundColor = [UIColor greenColor];
    }
    
    return cell;
}

- (void)queryAnswersForQuestion
{
    [stackOverflowAPI getAnswersByQuestionIds:@[[question valueForKey:@"question_id"]]
                          withResponseHandler:self
                                  andSelector:@selector(extractAnswerIdsForResponse:)];
    [self.tableView reloadData];
}

- (void)extractAnswerIdsForResponse:(NSDictionary *)response
{

    NSArray *items = response[@"items"];
    for (id answer in items){
        NSLog(@"Answer: %@", answer);
        
        NSDate *modificationDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [[answer objectForKey:@"last_activity_date"] doubleValue]];
        
        [self addCellDataWithOwnerName:answer[@"owner"][@"display_name"]
                                 score:(NSNumber *)answer[@"score"]
                          lastEditDate:modificationDate
                                QAText:answer[@"body"]
                                status:(NSNumber *)answer[@"is_accepted"]];
    }

    NSLog(@"Table data after receiving answers %@", self.tableData);
    [self.tableView reloadData];
}

- (void)addCellDataWithOwnerName:(NSString *)name
                           score:(NSNumber *)count
                    lastEditDate:(NSDate *)date
                          QAText:(NSString *)text
                      status:(NSNumber *)status
{
    if (date == nil){
        date = [[NSDate alloc]initWithTimeIntervalSinceNow:0];
    }
    
    NSDictionary *cellData = @{
                               @"owner_name": [NSString stringWithFormat:@"%@", name],
                               @"score": [NSString stringWithFormat:@"%@", count],
                               @"last_edit_date": [dateFormatter stringFromDate:date],
                               @"qa_text": [text stringByStrippingHTML],
                               @"status": status
                               };
    
    [self.tableData addObject:cellData];
}

@end
