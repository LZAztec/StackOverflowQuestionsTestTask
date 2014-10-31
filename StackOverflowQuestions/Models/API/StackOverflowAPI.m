//
//  StackOverflowQueryBuilder.m
//  StackOverflowQuestions
//
//  Created by Aztec on 07.10.14.
//  Copyright (c) 2014 Aztec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StackOverflowAPI.h"
#import "NSURL+PathParameters.h"
#import "NSCachedURLResponse+Expiration.h"
#import "UserSettings.h"

static NSString *const kAPIHost = @"https://api.stackexchange.com";
static NSString *const kAPIVersion = @"2.2";

@interface StackOverflowAPI()

- (NSString *)implode:(NSArray *)array;

@end


@implementation StackOverflowAPI

- (instancetype)init
{
    NSAssert(false, @"You cannot init this class directly. Instead, use initWithDelegate:");
    return nil;
}

- (instancetype)initWithDelegate:(id <StackOverflowAPIDelegate>)delegate;
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _settings = [UserSettings sharedInstance];
    }
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

    if (_settings.simulateQueriesState) {
        if ([self.delegate respondsToSelector:@selector(handleQuestionsByTagsResponse:)]) {
            [self.delegate handleQuestionsByTagsResponse:[self makeQuestionsStubResponse]];
        }
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

    if (_settings.simulateQueriesState) {
        if ([self.delegate respondsToSelector:@selector(handleAnswersByQuestionIdsResponse:)]) {
            [self.delegate handleAnswersByQuestionIdsResponse:[self makeAnswersByQuestionStubResponse]];
        }
    } else {
        [self executeQueryForUrlString:methodURLString andParams:params];
    }
}

- (void)executeQueryForUrlString:(NSString *)urlString andParams:(NSDictionary *)params
{
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
}

#pragma mark - Response processing methods
- (NSRegularExpression *)makeRegexForPattern:(NSString *)pattern
{
    // Create a regular expression
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;


    return [NSRegularExpression regularExpressionWithPattern:pattern
                                                     options:regexOptions
                                                       error:nil];
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

#pragma mark - NSURLConnection Delegate Methods

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
    // The request is complete and data has been received
    NSError *error = nil;
    NSDictionary *response = [self makeAPIResponseWithErrorHandling:&error];

    if ([response valueForKey:@"error_id"] != nil) {
        error = [NSError errorWithDomain:response[@"error_message"] code:[(NSString *)response[@"error_id"] integerValue] userInfo:response];
    }

    if (error != nil || response == nil) {
        if ([self.delegate respondsToSelector:@selector(handleError:)]) {
            [self.delegate handleError:error];
        } else {
            NSLog(@"Error occurred: %@", error);
        }

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
                            @"title" : @"Interpolation issue after renderInContext:UIGraphicsGetCurrentContext(), iOS",
                            @"body": @"<td class=\"postcell\">\n"
                            "<div>\n"
                            "    <div class=\"post-text\" itemprop=\"text\">\n"
                            "\n"
                            "        <p>A <code>NSInteger</code> is 32 bits on 32-bit platforms, and 64 bits on 64-bit platforms. Is there a <code>NSLog</code> specifier that always matches the size of <code>NSInteger</code>?</p>\n"
                            "\n"
                            "<p>Setup</p>\n"
                            "\n"
                            "<ul>\n"
                            "<li>Xcode 3.2.5</li>\n"
                            "<li>llvm 1.6 compiler <strong>(this is important; gcc doesn't do this)</strong></li>\n"
                            "<li><code>GCC_WARN_TYPECHECK_CALLS_TO_PRINTF</code> turned on</li>\n"
                            "</ul>\n"
                            "\n"
                            "<p>That's causing me some grief here:</p>\n"
                            "\n"
                            "<pre class=\"lang-c prettyprint prettyprinted\" style=\"\"><code><span class=\"com\">#import &lt;Foundation/Foundation.h&gt;</span><span class=\"pln\">\n"
                            "\n"
                            "</span><span class=\"typ\">int</span><span class=\"pln\"> main </span><span class=\"pun\">(</span><span class=\"typ\">int</span><span class=\"pln\"> argc</span><span class=\"pun\">,</span><span class=\"pln\"> </span><span class=\"kwd\">const</span><span class=\"pln\"> </span><span class=\"kwd\">char</span><span class=\"pln\"> </span><span class=\"pun\">*</span><span class=\"pln\"> argv</span><span class=\"pun\">[])</span><span class=\"pln\"> </span><span class=\"pun\">{</span><span class=\"pln\">\n"
                            "    </span><span class=\"lit\">@autoreleasepool</span><span class=\"pln\"> </span><span class=\"pun\">{</span><span class=\"pln\">\n"
                            "        </span><span class=\"typ\">NSInteger</span><span class=\"pln\"> i </span><span class=\"pun\">=</span><span class=\"pln\"> </span><span class=\"lit\">0</span><span class=\"pun\">;</span><span class=\"pln\">\n"
                            "        </span><span class=\"typ\">NSLog</span><span class=\"pun\">(@</span><span class=\"str\">\"%d\"</span><span class=\"pun\">,</span><span class=\"pln\"> i</span><span class=\"pun\">);</span><span class=\"pln\">\n"
                            "    </span><span class=\"pun\">}</span><span class=\"pln\">\n"
                            "    </span><span class=\"kwd\">return</span><span class=\"pln\"> </span><span class=\"lit\">0</span><span class=\"pun\">;</span><span class=\"pln\">\n"
                            "</span><span class=\"pun\">}</span></code></pre>\n"
                            "\n"
                            "<p>For 32 bit code, I need the <code>%d</code> specifier. But if I use the <code>%d</code> specifier, I get a warning when compiling for 64 bit suggesting I use <code>%ld</code> instead.</p>\n"
                            "\n"
                            "<p>If I use <code>%ld</code> to match the 64 bit size, when compiling for 32 bit code I get a warning suggesting I use <code>%d</code> instead.</p>\n"
                            "\n"
                            "<p>How do I fix both warnings at once? Is there a specifier I can use that works on either?</p>\n"
                            "\n"
                            "    </div>\n"
                            "    <div class=\"post-taglist\">\n"
                            "        <a href=\"/questions/tagged/objective-c\" class=\"post-tag js-gps-track\" title=\"\" rel=\"tag\">objective-c</a> <a href=\"/questions/tagged/cocoa\" class=\"post-tag js-gps-track\" title=\"show questions tagged 'cocoa'\" rel=\"tag\">cocoa</a> <a href=\"/questions/tagged/32bit-64bit\" class=\"post-tag js-gps-track\" title=\"show questions tagged '32bit-64bit'\" rel=\"tag\">32bit-64bit</a> <a href=\"/questions/tagged/nslog\" class=\"post-tag js-gps-track\" title=\"show questions tagged 'nslog'\" rel=\"tag\">nslog</a> <a href=\"/questions/tagged/nsinteger\" class=\"post-tag js-gps-track\" title=\"show questions tagged 'nsinteger'\" rel=\"tag\">nsinteger</a> \n"
                            "    </div>\n"
                            "    <table class=\"fw\">\n"
                            "    <tbody><tr>\n"
                            "    <td class=\"vt\">\n"
                            "<div class=\"post-menu\"><a href=\"/q/4405006\" title=\"short permalink to this question\" class=\"short-link\" id=\"link-post-4405006\">share</a><span class=\"lsep\">|</span><a href=\"/posts/4405006/edit\" class=\"suggest-edit-post\" title=\"\">improve this question</a></div>        \n"
                            "    </td>\n"
                            "    <td align=\"right\" class=\"post-signature\">\n"
                            "<div class=\"user-info user-hover\">\n"
                            "    <div class=\"user-action-time\">\n"
                            "        <a href=\"/posts/4405006/revisions\" title=\"show all edits to this post\">edited <span title=\"2014-06-28 09:55:26Z\" class=\"relativetime\">Jun 28 at 9:55</span></a>\n"
                            "    </div>\n"
                            "    <div class=\"user-gravatar32\">\n"
                            "        <a href=\"/users/231684/flexaddicted\"><div class=\"gravatar-wrapper-32\"><img src=\"http://i.stack.imgur.com/c7Et8.png?s=32&amp;g=1\" alt=\"\" width=\"32\" height=\"32\"></div></a>\n"
                            "    </div>\n"
                            "    <div class=\"user-details\">\n"
                            "        <a href=\"/users/231684/flexaddicted\">flexaddicted</a><br>\n"
                            "        <span class=\"reputation-score\" title=\"reputation score 16672\" dir=\"ltr\">16.7k</span><span title=\"13 gold badges\"><span class=\"badge1\"></span><span class=\"badgecount\">13</span></span><span title=\"63 silver badges\"><span class=\"badge2\"></span><span class=\"badgecount\">63</span></span><span title=\"112 bronze badges\"><span class=\"badge3\"></span><span class=\"badgecount\">112</span></span>\n"
                            "    </div>\n"
                            "</div>    </td>\n"
                            "    <td class=\"post-signature owner\">\n"
                            "        <div class=\"user-info user-hover\">\n"
                            "    <div class=\"user-action-time\">\n"
                            "        asked <span title=\"2010-12-10 01:58:25Z\" class=\"relativetime\">Dec 10 '10 at 1:58</span>\n"
                            "    </div>\n"
                            "    <div class=\"user-gravatar32\">\n"
                            "        <a href=\"/users/22927/steven-fisher\"><div class=\"gravatar-wrapper-32\"><img src=\"https://www.gravatar.com/avatar/488c2dcaa43806d49cac768901604ab5?s=32&amp;d=identicon&amp;r=PG\" alt=\"\" width=\"32\" height=\"32\"></div></a>\n"
                            "    </div>\n"
                            "    <div class=\"user-details\">\n"
                            "        <a href=\"/users/22927/steven-fisher\">Steven Fisher</a><br>\n"
                            "        <span class=\"reputation-score\" title=\"reputation score 23173\" dir=\"ltr\">23.2k</span><span title=\"13 gold badges\"><span class=\"badge1\"></span><span class=\"badgecount\">13</span></span><span title=\"82 silver badges\"><span class=\"badge2\"></span><span class=\"badgecount\">82</span></span><span title=\"135 bronze badges\"><span class=\"badge3\"></span><span class=\"badgecount\">135</span></span>\n"
                            "    </div>\n"
                            "</div>\n"
                            "    </td>\n"
                            "    </tr>\n"
                            "    </tbody></table>\n"
                            "</div>\n"
                            "</td>"
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
                            @"title": @"Answer!",
                            @"body": @"<html><body>Bla &quot;bla&quot; bla. That isn't an answer <code>Some code here...</code>It's a holy shit!</body></html>"
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
                            @"title":@"Answer!",
                            @"body": @"<html><body>Bla &quot;bla&quot; bla. That is an <code>NSLog(@\"Answer: %@\", answer)</code></body></html>"
                    }
            ],
            @"has_more" : @0,
            @"quota_max" : @10000,
            @"quota_remaining" : @9689
    };
}

@end
