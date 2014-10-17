//
//  QuestionTableViewCell.m
//  StackOverflowQuestions
//
//  Created by Aztec on 09.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "QATableViewCell.h"
#import "NSString+HTML.h"

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
        self.modificationDate.text = data[@"last_edit_date"];
        self.QAText.text = [(NSString *) data[@"qa_text"] stringByDecodingHTMLEntities];
        self.isAnsweredImageView.hidden = [(NSNumber *)data[@"status"] isEqualToNumber:@0];
    }
}

@end
