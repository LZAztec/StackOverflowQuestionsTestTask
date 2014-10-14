//
//  QuestionTableViewCell.m
//  StackOverflowQuestions
//
//  Created by Aztec on 09.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QATableViewCell.h"

@implementation QATableViewCell

@synthesize authorName;
@synthesize modificationDate;
@synthesize score;
@synthesize QAText;
@synthesize isAnsweredImageView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
