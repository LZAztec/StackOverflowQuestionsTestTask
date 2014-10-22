//
//  QuestionListViewCell.h
//  StackOverflowQuestions
//
//  Created by Aztec on 09.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellData.h"

@interface QuestionListViewCell : UITableViewCell <CellDataContainer>

@property (strong, nonatomic) IBOutlet UILabel *authorName;
@property (strong, nonatomic) IBOutlet UILabel *modificationDate;
@property (strong, nonatomic) IBOutlet UILabel *answerCount;
@property (strong, nonatomic) IBOutlet UILabel *questionText;

@end
