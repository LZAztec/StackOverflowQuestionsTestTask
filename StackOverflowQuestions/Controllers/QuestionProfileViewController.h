//
//  QuestionProfileViewController.h
//  StackOverflowQuestions
//
//  Created by Aztec on 08.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionsTableViewController.h"
#import "StackOverflowAPI.h"

@interface QuestionProfileViewController : UITableViewController <StackOverflowAPIDelegate>{
    NSDictionary *question;
    NSMutableArray *tableData;
    StackOverflowAPI *stackOverflowAPI;
    NSDateFormatter *dateFormatter;
}

@property (copy, nonatomic) NSDictionary *question;
@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) StackOverflowAPI *stackOverflowAPI;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end
