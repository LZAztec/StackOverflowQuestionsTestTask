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

- (void)setCellData:(StackOverflowResponseModelItem *)data
{
    self.authorName.text = [data.authorName stringByDecodingHTMLEntities];
    self.answerCount.text = [data.counter stringValue];

    self.modificationDate.text = [FormatHelper formatDateFuzzy:[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [data.creationDate doubleValue]]];
    self.questionText.text = [data.title stringByDecodingHTMLEntities];
}

@end
