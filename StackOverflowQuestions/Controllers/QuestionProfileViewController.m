//
//  QuestionProfileViewController.m
//  StackOverflowQuestions
//
//  Created by Aztec on 08.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QuestionProfileViewController.h"
#import "StackOverflowAPI.h"
#import "CustomTableViewCell.h"

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
                       answerCount:answerCount
                      lastEditDate:modificationDate
                             title:question[@"title"]];
    
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
    
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSDictionary *cellData = (NSDictionary *)[tableData objectAtIndex:indexPath.row];
    
    if (cellData){
        cell.authorName.text = cellData[@"owner_name"];
        cell.answerCount.text = cellData[@"answer_count"];
        cell.modificationDate.text = cellData[@"last_edit_date"];
        cell.questionText.text = cellData[@"title"];
    }
    
    if (indexPath.row == 0){
        cell.viewForBaselineLayout.backgroundColor = [UIColor greenColor];
    }
    
    return cell;
}

- (void)queryAnswersForQuestion
{
    [stackOverflowAPI getAnswersInfoByQuestionIds:@[[question valueForKey:@"question_id"]]
                              withResponseHandler:self
                                      andSelector:@selector(answersResponseReturned:)];
    [self.tableView reloadData];
}

- (void)answersResponseReturned:(NSDictionary *)response
{

    NSArray *items = response[@"items"];
    for (id answer in items){
        NSLog(@"Answer: %@", answer);
        NSNumber *answerCount = (NSNumber *)answer[@"answer_count"];
        
        NSDate *modificationDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [[answer objectForKey:@"last_activity_date"] doubleValue]];
        
        [self addCellDataWithOwnerName:answer[@"owner"][@"display_name"]
                           answerCount:answerCount
                          lastEditDate:modificationDate
                                 title:answer[@"title"]];
    }

    NSLog(@"Table data after receiving answers %@", self.tableData);
    [self.tableView reloadData];
}

- (void)addCellDataWithOwnerName:(NSString *)name answerCount:(NSNumber *)count lastEditDate:(NSDate *)date title:(NSString *)title
{
    if (date == nil){
        date = [[NSDate alloc]initWithTimeIntervalSinceNow:0];
    }
    
    NSDictionary *cellData = @{
                               @"owner_name": [NSString stringWithFormat:@"%@", name],
                               @"answer_count": [NSString stringWithFormat:@"%@", count],
                               @"last_edit_date": [dateFormatter stringFromDate:date],
                               @"title": [NSString stringWithFormat:@"%@", title]
                               };
    
    [self.tableData addObject:cellData];
}

@end
