//
//  QuestionListViewCell.h
//  StackOverflowQuestions
//
//  Created by Aztec on 09.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QACellData.h"

@interface QuestionProfileTableViewCell : UITableViewCell <CellDataContainer>

@property (weak, nonatomic) IBOutlet UILabel *authorName;
@property (weak, nonatomic) IBOutlet UILabel *modificationDate;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (weak, nonatomic) IBOutlet UITextView *QAText;
@property (weak, nonatomic) IBOutlet UIImageView *isAnsweredImageView;

@end
