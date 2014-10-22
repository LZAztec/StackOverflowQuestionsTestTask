//
//  QuestionProfileViewController.m
//  StackOverflowQuestions
//
//  Created by Aztec on 08.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QuestionProfileViewController.h"
#import "QuestionProfileTableViewCell.h"
#import "FormatterFactory.h"
#import "NSString+HTML.h"
#import "CellData.h"


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
    
    self.title = question.text;
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
    
    QuestionProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[QuestionProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    [cell setCellData:(CellData *)tableData[(NSUInteger) indexPath.row]];
    
    return cell;
}


#pragma mark -
#pragma mark Stack Overflow data processing
- (void)queryAnswersForQuestion
{
    [stackOverflowAPI getAnswersByQuestionIds:@[question.id]];
}

- (void)extractAnswersFromResponse:(NSDictionary *)response
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

    [self.tableView reloadData];
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

    CellData *cellData = [[CellData alloc] initWithAuthorName:name
                                                      counter:count
                                                 creationDate:creationDate
                                             lastModification:date
                                                       status:status
                                                         text:[text stringByDecodingHTMLEntities]
                                                           id:id
                                                         type:kCellDataAnswerType];

    [self.tableData addObject:cellData];
}

- (void)extractQuestionDataToFirstCell
{
    [self.tableData addObject:question];
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
