//
//  QuestionTableViewCell.h
//  StackOverflowQuestions
//
//  Created by Aztec on 09.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QATableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *authorName;
@property (strong, nonatomic) IBOutlet UILabel *modificationDate;
@property (strong, nonatomic) IBOutlet UILabel *score;
@property (strong, nonatomic) IBOutlet UITextView *QAText;
@property (strong, nonatomic) IBOutlet UIImageView *isAnsweredImageView;

- (void)setData:(NSDictionary *)data;

@end
