//
//  StackOverflowAPIDelegate.h
//  StackOverflowQuestions
//
//  Created by Aztec on 07.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol StackOverflowAPIDelegate <NSObject>
@required

- (void)handleRespone:(NSDictionary *)response;

@end
