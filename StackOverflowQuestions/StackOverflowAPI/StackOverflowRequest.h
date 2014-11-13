//
// Created by Aztec on 05.11.14.
// Copyright (c) 2014 Aztec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StackOverflowObject.h"
#import "StackOverflowResponse.h"
#import "StackOverflowResponseBaseModel.h"
#import "UserSettings.h"


@interface StackOverflowRequest : StackOverflowObject <NSURLConnectionDelegate>

/// Specify completion block for request
@property(nonatomic, copy) void (^completeBlock)(StackOverflowResponse *response);
/// Specity error (HTTP or API) block for request.
@property(nonatomic, copy) void (^errorBlock)(NSError *error);
/// Specify NSUrlConnection for request
@property(nonatomic, readonly) NSURLConnection *connection;
/// Timeout for this request
@property(nonatomic, assign) NSInteger requestTimeout;
/// Returns method for current request, e.g. questions
@property(nonatomic, strong) NSString *methodName;
/// Returns HTTP-method for current request
@property(nonatomic, strong) NSString *httpMethod;
/// Returns list of method parameters (without common parameters)
@property(nonatomic, strong) NSDictionary *methodParameters;
/// Return YES if current request was started
@property(nonatomic, readonly, getter=isExecuting) BOOL executing;
/// Set to NO if you don't need automatic model parsing
@property(nonatomic, assign) BOOL parseModel;
/// Use HTTPS requests (by default is YES). If http-request is impossible (user denied no https access), SDK will load https version
@property(nonatomic, assign) BOOL secure;
/// Specify attempts for request loading if caused HTTP-error. 0 for infinite
@property(nonatomic, assign) int attempts;
/// User settings for application
@property (weak, readonly) UserSettings* settings;

///-------------------------------
/// @name Preparing requests
///-------------------------------

/**
Creates new request with parameters. See documentation for methods here https://vk.com/dev/methods
@param method API-method name, e.g. audio.get
@param parameters method parameters
@param httpMethod HTTP method for execution, e.g. GET, POST
@return Complete request object for execute or configure method
*/
+ (instancetype)requestWithMethod:(NSString *)method andParameters:(NSDictionary *)parameters;

/**
Creates new request with parameters. See documentation for methods here https://vk.com/dev/methods
@param method API-method name, e.g. audio.get
@param parameters method parameters
@param httpMethod HTTP method for execution, e.g. GET, POST
@param modelClass class for automatic parse
@return Complete request object for execute or configure method
*/
+ (instancetype)requestWithMethod:(NSString *)method andParameters:(NSDictionary *)parameters classOfModel:(Class)modelClass;

///-------------------------------
/// @name Execution
///-------------------------------

/**
@param SuccessBlock called if there were no HTTP or API errors, returns execution result.
@param errorBlock called immediately if there was API error
*/
- (void)executeWithSuccessBlock:(void (^)(StackOverflowResponse *response))completeBlock
                    errorBlock:(void (^)(NSError *error))errorBlock;

/**
Starts loading of prepared request. You can use it instead of executeWithResultBlock
*/
- (void)start;
/**
Repeats this request with initial parameters and blocks.
Used attempts will be set to 0.
*/
- (void)repeat;
/**
Cancel current request. Result will be not passed. errorBlock will be called with error code
*/
- (void)cancel;

///-------------------------------
/// @name Operating with parameters
///-------------------------------
/**
Adds additional parameters to that request
@param extraParameters parameters supposed to be added
*/
- (void)addExtraParameters:(NSDictionary *)extraParameters;

@end