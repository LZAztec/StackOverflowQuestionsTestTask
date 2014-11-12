//
//  QuestionProfileViewController.h
//  StackOverflowQuestions
//
//  Created by Aztec on 08.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionListViewController.h"

@interface QuestionProfileViewController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate>{
    StackOverflowResponseModelItem *question;
    NSMutableArray *tableData;

    NSInteger _page;
    BOOL _hasMore;
}

@property (strong, nonatomic) StackOverflowResponseModelItem *question;
@property (strong, nonatomic) NSMutableArray *tableData;

@end
