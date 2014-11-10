//
//  QuestionListViewCell.h
//  StackOverflowQuestions
//
//  Created by Aztec on 09.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StackOverflowResponseModelItem.h"

@interface QuestionProfileTableViewCell : UITableViewCell <StackOverflowResponseModelItemContainer>

@property (weak, nonatomic) IBOutlet UILabel *authorName;
@property (weak, nonatomic) IBOutlet UILabel *modificationDate;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UITextView *QAText;
@property (weak, nonatomic) IBOutlet UIImageView *isAnsweredImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
