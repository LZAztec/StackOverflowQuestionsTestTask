//
//  QuestionListViewCell.m
//  StackOverflowQuestions
//
//  Created by Aztec on 09.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QuestionListViewCell.h"
#import "NSString+HTML.h"
#import "FormatHelper.h"

@implementation QuestionListViewCell

@synthesize authorName;
@synthesize modificationDate;
@synthesize answerCount;
@synthesize questionText;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellData:(StackOverflowResponseBaseModelItem *)data
{
    self.authorName.text = [data.authorName stringByDecodingHTMLEntities];
    self.answerCount.text = [data.counter stringValue];

    if ([data.creationDate isKindOfClass:NSDate.class]) {
        self.modificationDate.text = [FormatHelper formatDateFuzzy:data.creationDate];
    }

    self.questionText.text = [data.title stringByDecodingHTMLEntities];
}

@end
