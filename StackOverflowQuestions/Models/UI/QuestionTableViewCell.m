//
//  QuestionTableViewCell.m
//  StackOverflowQuestions
//
//  Created by Aztec on 09.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QuestionTableViewCell.h"
#import "NSString+HTML.h"
#import "FormatterFactory.h"
#import "FormatHelper.h"

@implementation QuestionTableViewCell

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

- (void)setData:(NSDictionary *)data;
{
    if (data) {
        self.authorName.text = [(NSString *) data[@"owner"][@"display_name"] stringByDecodingHTMLEntities];
        self.answerCount.text = [(NSNumber *) data[@"answer_count"] stringValue];

        NSDate *date = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) [data[@"creation_date"] doubleValue]];

        self.modificationDate.text = [FormatHelper formatDateFuzzy:date];
        self.questionText.text = [(NSString *)data[@"title"] stringByDecodingHTMLEntities];
    }
}

@end
