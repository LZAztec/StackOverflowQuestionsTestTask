//
//  QuestionListViewCell.m
//  StackOverflowQuestions
//
//  Created by Aztec on 09.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QuestionProfileTableViewCell.h"
#import "NSString+HTML.h"
#import "FormatHelper.h"

@implementation QuestionProfileTableViewCell

@synthesize authorName;
@synthesize modificationDate;
@synthesize score;
@synthesize QAText;
@synthesize isAnsweredImageView;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellData:(QACellData *)data
{
    self.authorName.text = [data.authorName stringByDecodingHTMLEntities];
    self.score.text = [data.counter stringValue];
    self.modificationDate.text = [FormatHelper formatDateFuzzy:data.lastModification];
    self.QAText.attributedText = [FormatHelper formatText:data.text
                               withCodeTagBackgroundColor:[UIColor brownColor]
                                                textColor:[UIColor whiteColor]];
    self.isAnsweredImageView.hidden = [data.status isEqualToNumber:@0];

    if (data.type == kCellDataQuestionType)
    {
        self.viewForBaselineLayout.backgroundColor = [UIColor colorWithRed:0.85 green:0.92 blue:0.79 alpha:1.0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.isAnsweredImageView.hidden = YES;
        self.modificationDate.text = [FormatHelper formatDateFuzzy:data.creationDate];
        self.score.hidden = YES;
    }
}

@end
