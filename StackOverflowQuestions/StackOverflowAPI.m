//
//  StackOverflowQueryBuilder.m
//  StackOverflowQuestions
//
//  Created by Aztec on 07.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "AFNetworking.h"
#import "StackOverflowAPI.h"

static NSString *const API_HOST = @"https://api.stackexchange.com";
static NSString *const API_VERSION = @"2.2";

@interface StackOverflowAPI()

- (NSString *)implode:(NSArray *)array;

@end


@implementation StackOverflowAPI

- (NSString *)implode:(NSArray *)array;
{
    return [[array valueForKey:@"description"] componentsJoinedByString:@";"];
}

- (void)makeResponseWithHandler:(id)handler
                         params:(NSDictionary *)params
                            url:(NSString *)url
                       selector:(SEL)selector
{
    if ([handler respondsToSelector:selector]){
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager GET:url
          parameters:params
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    [self performSelector:selector forHandler:handler withResponse:responseObject];
                 } else {
                    [self performSelector:selector forHandler:handler withResponse:@{}];
                 }
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"Error: %@", error);
                 [self performSelector:selector forHandler:handler withResponse:@{}];
             }
         ];
    } else {
        NSException *e = [NSException exceptionWithName:@"NotConformsToProtocolOrNotRespondsToSelectorException"
                                                 reason:[NSString stringWithFormat:@"Class \"%@\" not conforms to protocol \"%@\" or not responds to selector \"%@\"!", (NSString *) [handler class], @"StackOverflowAPIResponseHandler", NSStringFromSelector(selector)]
                                               userInfo:nil];
        @throw e;
    }
}

- (void)getQuestionsByTags:(NSArray *)tags withResponseHandler:(id)handler andSelector:(SEL)selector;
{
    NSDictionary *params = @{
         @"page": @1,
         @"pagesize": @50,
         @"order": @"desc",
         @"sort": @"creation",
         @"tagged": [self implode:tags],
         @"site": @"stackoverflow"
    };

    [self makeResponseWithHandler:handler
                           params:params
                              url:[NSString stringWithFormat:@"%@/%@/questions", API_HOST, API_VERSION]
                         selector:selector];
    
}

- (void)getAnswersInfoByQuestionIds:(NSArray *)ids withResponseHandler:(id)handler andSelector:(SEL)selector;
{
    NSDictionary *params = @{
         @"order": @"desc",
         @"sort": @"creation",
         @"site": @"stackoverflow"
    };
    
    NSLog(@"answers for question ids: %@", ids);

    [self makeResponseWithHandler:handler
                           params:params
                              url:[NSString stringWithFormat:@"%@/%@/questions/%@/answers", API_HOST, API_VERSION, [self implode:ids]]
                         selector:selector];
}

- (void)performSelector:(SEL)selector forHandler:(id)handler withResponse:(NSDictionary *)response;
{
    if ([handler respondsToSelector:selector]) {
        ((void (*)(id, SEL, NSDictionary *)) [handler methodForSelector:selector])(handler, selector, response);
    }
}

@end
