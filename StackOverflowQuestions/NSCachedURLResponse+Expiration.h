//
//  NSCachedURLResponse+Expiration.h
//  StackOverflowQuestions
//
//  Created by Aztec on 21.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCachedURLResponse (Expiration)

- (NSCachedURLResponse*)responseWithExpirationDuration:(int)duration;

@end
