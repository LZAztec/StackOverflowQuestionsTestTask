//
//  ViewController.h
//  StackOverflowQuestions
//
//  Created by Aztec on 07.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StackOverflowAPI.h"

@interface QuestionsTableViewController : UITableViewController <StackOverflowAPIDelegate>{
    NSArray *questions;
    StackOverflowAPI *stackOverflowAPI;
    UIActivityIndicatorView *activityIndicatorView;
    
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) NSArray *questions;
@property (strong, nonatomic) StackOverflowAPI *stackOverflowAPI;

- (void)tagSelected:(NSString *)tagName;

@end

