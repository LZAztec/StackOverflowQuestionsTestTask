//
//  QuestionProfileViewController.h
//  StackOverflowQuestions
//
//  Created by Aztec on 08.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionListViewController.h"
#import "StackOverflowAPI.h"

@class CellData;

@interface QuestionProfileViewController : UITableViewController <StackOverflowAPIDelegate>{
    CellData *question;
    NSMutableArray *tableData;
    StackOverflowAPI *stackOverflowAPI;
    NSDateFormatter *dateFormatter;
}

@property (strong, nonatomic) CellData *question;
@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) StackOverflowAPI *stackOverflowAPI;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end
