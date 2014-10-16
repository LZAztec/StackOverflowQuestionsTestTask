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

static NSString *const kAPIHost = @"https://api.stackexchange.com";
static NSString *const kAPIVersion = @"2.2";

@interface StackOverflowAPI()

- (NSString *)implode:(NSArray *)array;

@end


@implementation StackOverflowAPI

- (instancetype)initWithDelegate:(id <StackOverflowAPIDelegate>)delegate;
{
    if (self = [super init])
    {
        _delegate = delegate;
    }

    return self;
}

- (NSString *)implode:(NSArray *)array;
{
    return [[array valueForKey:@"description"] componentsJoinedByString:@";"];
}

- (void)getQuestionsByTags:(NSArray *)tags {
    NSDictionary *params = @{
            @"page" : @1,
            @"pagesize" : @50,
            @"order" : @"desc",
            @"sort" : @"creation",
            @"tagged" : [self implode:tags],
            @"site" : @"stackoverflow",
            @"filter" : @"withbody"
    };

    NSString *methodURLString = [NSString stringWithFormat:@"%@/%@/questions", kAPIHost, kAPIVersion];

    [self executeQueryForUrlString:methodURLString andParams:params];
}

- (void)getAnswersByQuestionIds:(NSArray *)ids
{
    NSDictionary *params = @{
            @"order": @"desc",
            @"sort": @"creation",
            @"site": @"stackoverflow",
            @"filter": @"withbody"
    };


    NSString *methodURLString = [NSString stringWithFormat:@"%@/%@/questions/%@/answers", kAPIHost, kAPIVersion, [self implode:ids]];

    [self executeQueryForUrlString:methodURLString andParams:params];
}

- (void)executeQueryForUrlString:(NSString *)urlString andParams:(NSDictionary *)params
{
    NSURL *methodURL = [NSURL URLWithString:urlString];

    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[methodURL URLByAppendingParameters:params]];

    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

#pragma mark -
#pragma mark Response processing methods
- (NSRegularExpression *)makeRegexForPattern:(NSString *)pattern {
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

- (NSDictionary *)makeAPIResponseWithErrorHandling:(NSError **)error {
    NSLog(@"Response NSData: %@", _responseData);

    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:_responseData
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:error];
    _responseData = nil;

    NSLog(@"responseDict=%@",responseDict);

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
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // The request is complete and data has been received
    NSError *error = nil;
    NSDictionary *response = [self makeAPIResponseWithErrorHandling:&error];

    if (response == nil && [self.delegate respondsToSelector:@selector(handleError:)]) {
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


@end
