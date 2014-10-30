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

@class StackOverflowResponseData;

@interface QuestionProfileViewController : UITableViewController <StackOverflowAPIDelegate, UIAlertViewDelegate>{
    StackOverflowResponseData *question;
    NSMutableArray *tableData;
    StackOverflowAPI *stackOverflowAPI;

    NSInteger _page;
    BOOL _hasMore;
}

@property (strong, nonatomic) StackOverflowResponseData *question;
@property (strong, nonatomic) NSMutableArray *tableData;
@property (strong, nonatomic) StackOverflowAPI *stackOverflowAPI;

@end
