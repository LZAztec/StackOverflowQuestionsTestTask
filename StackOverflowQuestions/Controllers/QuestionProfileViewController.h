//
//  QuestionProfileViewController.h
//  StackOverflowQuestions
//
//  Created by Aztec on 08.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionListViewController.h"
#import "VKontakteActivity.h"

@interface QuestionProfileViewController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate, VKontakteActivityProtocol>

@property (nonatomic, strong) StackOverflowResponseBaseModelItem *question;
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL hasMore;

@end
