//
//  NSCachedURLResponse+Expiration.m
//  StackOverflowQuestions
//
//  Created by Aztec on 21.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "NSCachedURLResponse+Expiration.h"

@implementation NSCachedURLResponse (Expiration)

- (NSCachedURLResponse*)responseWithExpirationDuration:(int)duration
{
    NSCachedURLResponse* cachedResponse = self;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)[cachedResponse response];
    NSDictionary *headers = [httpResponse allHeaderFields];
    NSMutableDictionary* newHeaders = [headers mutableCopy];
    
    newHeaders[@"Cache-Control"] = [NSString stringWithFormat:@"max-age=%i", duration];
    [newHeaders removeObjectForKey:@"Expires"];
    [newHeaders removeObjectForKey:@"s-maxage"];
    
    NSHTTPURLResponse* newResponse = [[NSHTTPURLResponse alloc] initWithURL:httpResponse.URL
                                                                 statusCode:httpResponse.statusCode
                                                                HTTPVersion:@"HTTP/1.1"
                                                               headerFields:newHeaders];
    
    cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:newResponse
                                                              data:[cachedResponse.data mutableCopy]
                                                          userInfo:newHeaders
                                                     storagePolicy:cachedResponse.storagePolicy];
    return cachedResponse;
}

@end
