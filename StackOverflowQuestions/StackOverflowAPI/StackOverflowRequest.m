//
// Created by Aztec on 05.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import "StackOverflowRequest.h"
#import "NSCachedURLResponse+Expiration.h"
#import "NSURL+PathParameters.h"
#import "StackOverflowResponseDataStubs.h"
#import "StackOverflowResponseFactory.h"

static NSString *const kAPIHost = @"api.stackexchange.com";
static NSString *const kAPIVersion = @"2.2";

@interface StackOverflowRequest ()

/// Class for model parsing
@property (nonatomic, strong) Class modelClass;
/// Paths to photos
@property (nonatomic, strong) NSArray *photoObjects;
/// How much times request was loaded
@property (readwrite, assign) int attemptsUsed;
/// This request response
@property (nonatomic, strong) StackOverflowResponse *response;
/// This request error
@property (nonatomic, strong) NSError *error;
/// Specify NSUrlConnection for request
@property (nonatomic, readwrite) NSURLConnection *connection;
/// User settings for application
@property (strong, readwrite) UserSettings* settings;
/// Return YES if current request was started
@property (nonatomic, readwrite) BOOL executing;

@end

@implementation StackOverflowRequest
{
    NSMutableData *_responseData;
}

#pragma mark Init

+ (instancetype)requestWithMethod:(NSString *)method
                    andParameters:(NSDictionary *)parameters
{
    StackOverflowRequest *newRequest = [self new];

    newRequest.methodName       = method;
    newRequest.methodParameters = parameters;
    return newRequest;
}

+ (instancetype)requestWithMethod:(NSString *)method
                    andParameters:(NSDictionary *)parameters
                     classOfModel:(Class)modelClass
{
    StackOverflowRequest *request = [self requestWithMethod:method andParameters:parameters];
    request.modelClass = modelClass;
    return request;
}

- (id)init
{
    self = [super init];

    if (self) {
        self.attemptsUsed       = 0;
        self.secure             = YES;
        //By default there is 1 attempt for loading.
        self.attempts           = 1;
        self.requestTimeout     = 30;
        //Common parameters
        self.parseModel         = YES;
        //TODO realize customizing http-method. refactor "start" method. move connection code to http-client class
        self.httpMethod         = @"GET";
        self.settings           = [UserSettings sharedInstance];
    }
    return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<StackOverflowRequest: %p>\nMethod: %@ (%@)\nparameters: %@", self, _methodName, _httpMethod, _methodParameters];
//    return [NSString stringWithFormat:@"<StackOverflowRequest: %p; Method: %@ (%@)>", self, self.methodName, self.httpMethod];
}

#pragma mark - Execution

- (void)executeWithSuccessBlock:(void (^)(StackOverflowResponse *))completeBlock
                     errorBlock:(void (^)(NSError *))errorBlock
{
    self.completeBlock = completeBlock;
    self.errorBlock    = errorBlock;

    [self start];
}

- (void)start
{
    if (self.isExecuting) {
        [self cancel];
    }

    self.executing = YES;

    if (self.settings.simulateQueries) {
        [self provideResponse:[StackOverflowResponseDataStubs jsonForMethod:self.methodName]];
    } else {
        NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http%@://%@/%@", self.secure ? @"s":@"", kAPIHost, kAPIVersion]];

        NSURL *url = nil;
        if ([self.methodName hasPrefix:@"http"])
            url = [NSURL URLWithString:self.methodName];
        else
            url = [NSURL URLWithString:self.methodName relativeToURL:apiUrl];

        url = [url URLByAppendingParameters:self.methodParameters];
        NSLog(@"URL for Request: %@, methodName: %@", [url absoluteString], self.methodName);

        // Create the request
        NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:self.requestTimeout];

        self.attemptsUsed++;
        // Create url connection and fire request
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [self.connection start];
    }
}

- (void)repeat
{
    self.attemptsUsed = 0;
    [self start];
}

- (void)cancel
{
    NSLog(@"----Cancel request----");
    [self.connection cancel];
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
    NSError *error = nil;
    // The request is complete and data has been received
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];

    if ([JSON valueForKey:@"error_id"] != nil) {
        error = [NSError errorWithDomain:JSON[@"error_message"] code:[(NSString *) JSON[@"error_id"] integerValue] userInfo:JSON];
    }

    if (error != nil ) {
        [self retryOrExecuteErrorBlock:error];
        return;
    }

    [self provideResponse:JSON];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // The request has failed for some reason!
    // Check the error var
    [self retryOrExecuteErrorBlock:error];
}

- (void)provideResponse:(NSDictionary *)JSON
{
    StackOverflowResponse *response = [StackOverflowResponse new];
    response.request = self;
    response.json = JSON;

    if (self.parseModel) {
        response.parsedModel = [StackOverflowResponseFactory responseWithDictionary:JSON
                                                                             method:self.methodName
                                                                              model:self.modelClass];
    }

    self.response = response;
    [self finishRequest];
}

- (void)finishRequest
{
    self.executing = NO;
    if (self.error) {
        [self retryOrExecuteErrorBlock:self.error];
    } else {
        [self executeCompleteBlock:self.response];
    }
    self.response = nil;
    self.error    = nil;
    _responseData = nil;
}

- (void)retryOrExecuteErrorBlock:(NSError *)error
{
    self.executing = NO;
    NSLog(@"Error occurred: %@", error);
    // Retry only if attempts was set and it greater than used attempts count
    if (self.attemptsUsed < self.attempts) {
        [self start];
        return;
    }
    if (self.errorBlock) {
        self.errorBlock(error);
    }
}

- (void)executeCompleteBlock:(StackOverflowResponse *)response
{
    if (self.completeBlock) {
        self.completeBlock(self.response);
    } else {
        NSLog(@"Request was finished! Response: %@", response);
    }
}

- (void)addExtraParameters:(NSDictionary *)extraParameters;
{
    if (!self.methodParameters)
        self.methodParameters = [extraParameters mutableCopy];
    else {
        NSMutableDictionary *params = [_methodParameters mutableCopy];
        [params addEntriesFromDictionary:extraParameters];
        self.methodParameters = params;
    }
}

@end