//
//  QuestionTableViewCell.m
//  StackOverflowQuestions
//
//  Created by Aztec on 09.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QATableViewCell.h"
#import "NSString+HTML.h"
#import "NSString+Additions.h"
#import "UITextView+Additions.h"
#import "FormatHelper.h"

@implementation QATableViewCell

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

- (void)setData:(NSDictionary *)data
{
    if (data) {
        self.authorName.text = [(NSString *) data[@"owner_name"] stringByDecodingHTMLEntities];
        self.score.text = data[@"counter"];
        self.modificationDate.text = [FormatHelper formatDateFuzzy:data[@"last_edit_date"]];
        [self setQATextData:(NSString *) data[@"qa_text"]];
        self.isAnsweredImageView.hidden = [(NSNumber *)data[@"status"] isEqualToNumber:@0];
    }
}

- (void)setQATextData:(NSString *)text
{
    // Replace tags (<code> & </code>) with non html compliant analog (%code% & %/code%)
    text = [text stringByReplacingOccurrencesOfString:@"<code>" withString:@"%code%"];
    text = [text stringByReplacingOccurrencesOfString:@"</code>" withString:@"%/code%"];
    
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
