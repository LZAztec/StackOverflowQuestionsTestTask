//
//  VKontakteActivity.h
//  StackOverflowQuestions
//
//  Created by Aztec on 28.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VKontakteActivity : UIActivity

@property (nonatomic, copy) NSString *appID;

- (id)initWithParent:(UIViewController*)parent;

@end