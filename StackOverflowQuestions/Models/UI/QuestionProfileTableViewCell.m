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
    self.QAText.attributedText = [self attributedFormattedStringFromString:data.text];
    
    self.isAnsweredImageView.hidden = [data.status isEqualToNumber:@0];

    if (data.type == kCellDataQuestionType) {
        self.viewForBaselineLayout.backgroundColor = [UIColor colorWithRed:0.85 green:0.92 blue:0.79 alpha:1.0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.isAnsweredImageView.hidden = YES;
        self.score.hidden = YES;
    } else {
        self.viewForBaselineLayout.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.score.hidden = NO;
    }
    
}

- (NSMutableAttributedString *)attributedFormattedStringFromString:(NSString *)string
{
    NSMutableAttributedString *QATextAttributedString = [FormatHelper formatText:string
                                                      withCodeTagBackgroundColor:[UIColor brownColor]
                                                                       textColor:[UIColor whiteColor]];
    
    // Set font, notice the range is for the whole string
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:14];
    
    [QATextAttributedString addAttribute:NSFontAttributeName
                                   value:font
                                   range:NSMakeRange(0, [QATextAttributedString length])];

    return QATextAttributedString;
}

@end
