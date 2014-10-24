//
//  StackOverflowQueryBuilder.m
//  StackOverflowQuestions
//
//  Created by Aztec on 07.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import "AFNetworking.h"
#import "StackOverflowAPI.h"
#import "NSURL+PathParameters.h"
#import "NSCachedURLResponse+Expiration.h"

static NSString *const kAPIHost = @"https://api.stackexchange.com";
static NSString *const kAPIVersion = @"2.2";

@interface StackOverflowAPI()

- (NSString *)implode:(NSArray *)array;

@end


@implementation StackOverflowAPI

- (instancetype)initWithDelegate:(id <StackOverflowAPIDelegate>)delegate;
{
    self = [super init];

    if (!self)
    {
        return nil;
    }

    _delegate = delegate;
    _processingQuery = NO;

    return self;
}

- (NSString *)implode:(NSArray *)array;
{
    return [[array valueForKey:@"description"] componentsJoinedByString:@";"];
}

- (void)getQuestionsByTags:(NSArray *)tags page:(NSNumber *)page limit:(NSNumber *)limit
{
    NSDictionary *params = @{
            @"page" : page,
            @"pagesize" : limit,
            @"order" : @"desc",
            @"sort" : @"creation",
            @"tagged" : [self implode:tags],
            @"site" : @"stackoverflow",
            @"filter" : @"withbody"
    };

    NSString *methodURLString = [NSString stringWithFormat:@"%@/%@/questions", kAPIHost, kAPIVersion];

    if (self.simulateQueries) {
        [self.delegate handleQuestionsByTagsResponse:[self makeQuestionsStubResponse]];
    } else {
        [self executeQueryForUrlString:methodURLString andParams:params];
    }

}

- (void)getAnswersByQuestionIds:(NSArray *)ids page:(NSNumber *)page limit:(NSNumber *)limit
{
    NSDictionary *params = @{
            @"page" : page,
            @"pagesize" : limit,
            @"order": @"desc",
            @"sort": @"creation",
            @"site": @"stackoverflow",
            @"filter": @"withbody"
    };


    NSString *methodURLString = [NSString stringWithFormat:@"%@/%@/questions/%@/answers", kAPIHost, kAPIVersion, [self implode:ids]];

    if (self.simulateQueries) {
        [self.delegate handleAnswersByQuestionIdsResponse:[self makeAnswersByQuestionStubResponse]];
    } else {
        [self executeQueryForUrlString:methodURLString andParams:params];
    }
}

- (void)executeQueryForUrlString:(NSString *)urlString andParams:(NSDictionary *)params
{
    if (!_processingQuery) {
        _processingQuery = YES;
        [_responseData setLength:0];

        NSURL *methodURL = [NSURL URLWithString:urlString];

        // Set response timeout
        NSTimeInterval timeout = 15;

        // Create the request
        NSURLRequest *request = [NSURLRequest requestWithURL:[methodURL URLByAppendingParameters:params]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:timeout];

        // Create url connection and fire request
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [conn start];
    } else {
        NSLog(@"Query is already in process! Try later");
    }
}

#pragma mark -
#pragma mark Response processing methods
- (NSRegularExpression *)makeRegexForPattern:(NSString *)pattern
{
    // Create a regular expression
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;


    return [NSRegularExpression regularExpressionWithPattern:pattern
                                                     options:regexOptions
                                                       error:&error];
}

- (BOOL)url:(NSURL *)url matchesPattern:(NSString *)pattern
{
    NSRegularExpression *regex = [self makeRegexForPattern:pattern];
    NSString *URLString = url.absoluteString;

    NSArray *matches = [regex matchesInString:URLString
                                      options:NSMatchingReportProgress
                                        range:NSMakeRange(0, URLString.length)];

    return [matches count] > 0;
}

- (NSDictionary *)makeAPIResponseWithErrorHandling:(NSError **)error
{
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:_responseData
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:error];

    return responseDict;
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    // Set time to live in cache to 5 minutes
    return [cachedResponse responseWithExpirationDuration:(60*5)];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _processingQuery = NO;

    // The request is complete and data has been received
    NSError *error = nil;
    NSDictionary *response = [self makeAPIResponseWithErrorHandling:&error];

    if (response == nil && [self.delegate respondsToSelector:@selector(handleError:)]) {
        const unsigned char *ptr = [_responseData bytes];

        for(int i=0; i<[_responseData length]; ++i) {
            unsigned char c = *ptr++;
            NSLog(@"Unprintable character exists! char=%c hex=%x", c, c);
        }

        [self.delegate handleError:error];
        return;
    }

    if ([self url:connection.originalRequest.URL matchesPattern:@"^.*/questions(/){0,1}\?"] &&
            [self.delegate respondsToSelector:@selector(handleQuestionsByTagsResponse:)]) {
        [self.delegate handleQuestionsByTagsResponse:response];
    }
    else if ([self url:connection.originalRequest.URL matchesPattern:@"/questions/(\\d+;{0,1})+/answers(/){0,1}\?"] &&
            [self.delegate respondsToSelector:@selector(handleAnswersByQuestionIdsResponse:)]) {
        [self.delegate handleAnswersByQuestionIdsResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // The request has failed for some reason!
    // Check the error var
    [self.delegate handleError:error];
}


#pragma mark - Stubs: Responses
- (NSDictionary *)makeQuestionsStubResponse
{
    return @{
            @"items" : @[
                    @{
                            @"tags" : @[
                                    @"ios",
                                    @"uiview",
                                    @"interpolation",
                                    @"cglayer"
                            ],
                            @"owner" : @{
                                    @"reputation" : @1476,
                                    @"user_id" : @1408546,
                                    @"user_type" : @"registered",
                                    @"accept_rate" : @89,
                                    @"profile_image" : @"https://www.gravatar.com/avatar/17ecfb60676a98e576ecc54ada8db67b?s=128&d=identicon&r=PG",
                                    @"display_name" : @"Mrwolfy",
                                    @"link" : @"http://stackoverflow.com/users/1408546/mrwolfy"
                            },
                            @"is_answered" : @0,
                            @"view_count" : @129,
                            @"answer_count" : @2,
                            @"score" : @1,
                            @"last_activity_date" : @1414070722,
                            @"creation_date" : @1366887889,
                            @"question_id" : @16213079,
                            @"link" : @"http://stackoverflow.com/questions/16213079/interpolation-issue-after-renderincontextuigraphicsgetcurrentcontext-ios",
                            @"title" : @"Interpolation issue after renderInContext:UIGraphicsGetCurrentContext(), iOS"
                    }
            ],
            @"has_more" : @1,
            @"quota_max" : @10000,
            @"quota_remaining" : @9698
    };
}

- (NSDictionary *)makeAnswersByQuestionStubResponse
{
    return @{
            @"items" : @[
                    @{
                            @"owner" : @{
                                    @"reputation" : @467,
                                    @"user_id" : @673363,
                                    @"user_type" : @"registered",
                                    @"profile_image" : @"https://www.gravatar.com/avatar/c42be5b468abc88ec114a92ad037c596?s=128&d=identicon&r=PG",
                                    @"display_name" : @"Rasmus Taulborg Hummelmose",
                                    @"link" : @"http://stackoverflow.com/users/673363/rasmus-taulborg-hummelmose"
                            },
                            @"is_accepted" : @0,
                            @"score" : @0,
                            @"last_activity_date" : @1414070722,
                            @"creation_date" : @1414070722,
                            @"answer_id" : @26529146,
                            @"question_id" : @16213079,
                            @"body": @"<html><body>Bla &quot;bla&quot; bla. That isn't an answer <code>Some code here...</code></body></html>"
                    },
                    @{
                            @"owner" : @{
                            @"reputation" : @467,
                            @"user_id" : @673363,
                            @"user_type" : @"registered",
                            @"profile_image" : @"https://www.gravatar.com/avatar/c42be5b468abc88ec114a92ad037c596?s=128&d=identicon&r=PG",
                            @"display_name" : @"Rasmus Taulborg Hummelmose",
                            @"link" : @"http://stackoverflow.com/users/673363/rasmus-taulborg-hummelmose"
                    },
                            @"is_accepted" : @1,
                            @"score" : @5,
                            @"last_activity_date" : @1414070722,
                            @"creation_date" : @1414070722,
                            @"answer_id" : @26529146,
                            @"question_id" : @16213079,
                            @"body": @"<html><body>Bla &quot;bla&quot; bla. That is an <code>NSLog(@\"Answer: %@\", answer)</code></body></html>"
                    }
            ],
            @"has_more" : @0,
            @"quota_max" : @10000,
            @"quota_remaining" : @9689
    };
}

@end
