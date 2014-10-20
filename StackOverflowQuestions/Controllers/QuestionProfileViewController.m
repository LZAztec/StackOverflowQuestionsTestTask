//
//  QuestionProfileViewController.m
//  StackOverflowQuestions
//
//  Created by Aztec on 08.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QuestionProfileViewController.h"
#import "QATableViewCell.h"
#import "NSString+Additions.h"
#import "FormatterFactory.h"

@interface QuestionProfileViewController ()

@end

@implementation QuestionProfileViewController

@synthesize question;
@synthesize tableData;
@synthesize stackOverflowAPI;
@synthesize dateFormatter;

#pragma mark -
#pragma mark Lifecycle
- (void)viewDidLoad {
    
    self.tableData = [[NSMutableArray alloc]init];
    
    self.title = [question valueForKey:@"title"];
    self.stackOverflowAPI = [[StackOverflowAPI alloc] initWithDelegate:self];

    dateFormatter = [FormatterFactory getDefaultDateTimeFormatter];
    
    [self extractQuestionDataToFirstCell];
    [self queryAnswersForQuestion];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark UI Table View Methods
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
    
    [cell setData:(NSDictionary *) tableData[(NSUInteger) indexPath.row]];
    
    if (indexPath.row == 0){
        cell.viewForBaselineLayout.backgroundColor = [UIColor colorWithRed:0.85 green:0.92 blue:0.79 alpha:1.0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}


#pragma mark -
#pragma mark Stack Overflow data processing
- (void)queryAnswersForQuestion
{
    [stackOverflowAPI getAnswersByQuestionIds:@[[question valueForKey:@"question_id"]]];
}

- (void)extractAnswersFromResponse:(NSDictionary *)response
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

    text = [text stringByReplacingOccurrencesOfRegex:@"<code>" withString:@"\n"];
    
    NSDictionary *cellData = @{
                               @"owner_name": [NSString stringWithFormat:@"%@", name],
                               @"counter": [NSString stringWithFormat:@"%@", count],
                               @"last_edit_date": [dateFormatter stringFromDate:date],
                               @"qa_text": [text stringByStrippingHTML],
                               @"status": status
                               };
    
    [self.tableData addObject:cellData];
}

- (void)extractQuestionDataToFirstCell
{
    
    NSNumber *answerCount = (NSNumber *) question[@"answer_count"];
    
    NSDate *modificationDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [question[@"last_edit_date"] doubleValue]];
    
    [self addCellDataWithOwnerName:(NSString *) question[@"owner"][@"display_name"]
                             score:answerCount
                      lastEditDate:modificationDate
                            QAText:question[@"title"]
                            status:@0];
    
}

#pragma -
#pragma Stack Overflow API Delegate methods
- (void)handleAnswersByQuestionIdsResponse:(NSDictionary *)response {
    [self extractAnswersFromResponse:response];
}

- (void)handleError:(NSError *)error {
    NSLog(@"Error happened:%@", error);
}

@end
