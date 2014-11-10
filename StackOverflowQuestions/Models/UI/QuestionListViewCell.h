//
//  QuestionListViewCell.h
//  StackOverflowQuestions
//
//  Created by Aztec on 09.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StackOverflowResponseModelItem.h"

@interface QuestionListViewCell : UITableViewCell <StackOverflowResponseModelItemContainer>

@property (weak, nonatomic) IBOutlet UILabel *authorName;
@property (weak, nonatomic) IBOutlet UILabel *modificationDate;
@property (weak, nonatomic) IBOutlet UILabel *answerCount;
@property (weak, nonatomic) IBOutlet UILabel *questionText;

@end
