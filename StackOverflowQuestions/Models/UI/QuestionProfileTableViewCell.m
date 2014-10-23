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
    [self setQATextData:data.text];
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

- (void)setQATextData:(NSString *)text
{
    // Replace tags (<code> & </code>) with non html compliant analog (%code% & %/code%)
    text = [text stringByReplacingOccurrencesOfString:@"<code>" withString:@"%code%"];
    text = [text stringByReplacingOccurrencesOfString:@"</code>" withString:@"%/code%"];
    if (text.length > 0){
        NSMutableAttributedString *newText = [[NSMutableAttributedString alloc] initWithString:[text stringByConvertingHTMLToPlainText]];

        NSRegularExpression *regex = [self makeRegexForPattern:@"%code%.*%/code%"];

        // Find matches
        NSArray *matches = [regex matchesInString:newText.string
                                          options:NSMatchingReportProgress
                                            range:NSMakeRange(0, newText.length)];

        // Iterate through the matches and highlight them
        for (NSTextCheckingResult *match in matches)
        {
            NSRange matchRange = match.range;
            // Decrease range to exlude tags (non html compliant analog) from highlight
            matchRange.location += 6;
            matchRange.length -= 7;

            [newText addAttribute:NSBackgroundColorAttributeName
                            value:[UIColor brownColor]
                            range:matchRange];
            [newText addAttribute:NSForegroundColorAttributeName
                            value:[UIColor whiteColor]
                            range:matchRange];
        }

        self.QAText.attributedText = [self mutableAttributedStringByReplacingPattern:@"%/{0,1}code%"
                                                                         replacement:@"\n"
                                                             mutableAttributedString:newText];
    }

}

- (NSMutableAttributedString *)mutableAttributedStringByReplacingPattern:(NSString *)pattern
                                               replacement:(NSString *)replacement
                                          mutableAttributedString:(NSMutableAttributedString *)attributedString
{
    NSRegularExpression *regex = [self makeRegexForPattern:@"%/{0,1}code%"];
    
    NSArray *matches = [regex matchesInString:attributedString.string
                             options:NSMatchingReportProgress
                               range:NSMakeRange(0, attributedString.length)];
    
    if (matches.count > 0) {
        NSTextCheckingResult *matchCode = matches[0];
        [attributedString replaceCharactersInRange:matchCode.range withString:replacement];
        attributedString = [self mutableAttributedStringByReplacingPattern:pattern replacement:replacement mutableAttributedString:attributedString];
    }
    
    return attributedString;
}

// Create a regular expression with given pattern
- (NSRegularExpression *)makeRegexForPattern:(NSString *)pattern {
    // Create a regular expression
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
    
    
    return [NSRegularExpression regularExpressionWithPattern:pattern
                                                     options:regexOptions
                                                       error:&error];
}

@end
