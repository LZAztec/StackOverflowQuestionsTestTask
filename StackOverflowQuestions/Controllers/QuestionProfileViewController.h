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

@interface QuestionProfileViewController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate, VKontakteActivityProtocol>{
    StackOverflowResponseBaseModelItem *question;
    NSMutableArray *tableData;

    NSInteger _page;
    BOOL _hasMore;
}

@property (strong, nonatomic) StackOverflowResponseBaseModelItem *question;
@property (strong, nonatomic) NSMutableArray *tableData;

@end
