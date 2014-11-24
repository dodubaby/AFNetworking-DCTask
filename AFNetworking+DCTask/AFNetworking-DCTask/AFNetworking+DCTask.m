//
//  AFNetworking+DCTask.m
//  Daltoniam
//
//  Created by bright on 14/11/3.
//  Copyright (c) 2014年 mtf. All rights reserved.
//

#import "AFNetworking+DCTask.h"


#define DCTaskHTTPOperationResponse(operation,responseObject) \
[DCTaskHTTPOperationResponse dc_operationResponseWithOperation:operation object:responseObject]

#define DCTaskHTTPSessionResponse(task,responseObject) \
[DCTaskHTTPSessionResponse dc_taskResponseWithTask:task object:responseObject]

@implementation DCTaskHTTPOperationResponse

+ (DCTaskHTTPOperationResponse *)dc_operationResponseWithOperation:(AFHTTPRequestOperation *)operation
                                                     object:(id)responseObject{
    DCTaskHTTPOperationResponse *response = [DCTaskHTTPOperationResponse new];
    response.operation = operation;
    response.responseObject = responseObject;
    return response;
}

@end

@implementation DCTaskHTTPSessionResponse

+ (DCTaskHTTPSessionResponse *)dc_taskResponseWithTask:(NSURLSessionDataTask *)task
                                                 object:(id)responseObject{
    DCTaskHTTPSessionResponse *response = [DCTaskHTTPSessionResponse new];
    response.task = task;
    response.responseObject = responseObject;
    return response;
}

@end


@implementation AFHTTPRequestOperation (DCTask)

- (DCTask *)dc_task
{
    return [self dc_taskByStartingImmediately:NO];
}

- (DCTask *)dc_taskAndStartImmediately
{
    return [self dc_taskByStartingImmediately:YES];
}

- (DCTask *)dc_taskByStartingImmediately:(BOOL)startImmediately
{
    return [DCTask newAsyncTask:^(DCAsyncTaskSuccess success, DCAsyncTaskFailure failure) {
        [self setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            success(DCTaskHTTPOperationResponse(operation, responseObject));
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            id info = error.userInfo.mutableCopy;
            info[dc_AFHTTPRequestOperationErrorKey] = operation;
            id newerror = [NSError errorWithDomain:error.domain code:error.code userInfo:info];
            failure(newerror);
        }];
        
        if (startImmediately) {
            [self start];
        }
    }];
}

+ (DCTask *)dc_request:(NSURLRequest *)request
{
    NSOperationQueue *q = [NSOperationQueue currentQueue] ? : [NSOperationQueue mainQueue];
    return [self dc_request:request queue:q];
}

+ (DCTask *)dc_request:(NSURLRequest *)request queue:(NSOperationQueue *)queue
{
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [queue addOperation:operation];
    return [operation dc_task];
}


@end

@implementation AFHTTPRequestOperationManager(DCTask)

- (DCTask *)dc_POST:(NSString *)URLString parameters:(id)parameters
{
    return [[self POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {} failure:^(AFHTTPRequestOperation *operation, NSError *error) {}] dc_task];
}

- (DCTask *)dc_POST:(NSString *)URLString parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
{
    return [[self POST:URLString parameters:parameters constructingBodyWithBlock:block success:nil failure:nil] dc_task];
}

- (DCTask *)dc_GET:(NSString *)URLString parameters:(id)parameters
{
    return [[self GET:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {} failure:^(AFHTTPRequestOperation *operation, NSError *error) {}] dc_task];
}

- (DCTask *)dc_PUT:(NSString *)URLString parameters:(id)parameters;
{
    return [[self PUT:URLString parameters:parameters success:nil failure:nil] dc_task];
}

- (DCTask *)dc_DELETE:(NSString *)URLString parameters:(id)parameters
{
    return [[self DELETE:URLString parameters:parameters success:nil failure:nil] dc_task];
}

- (DCTask *)dc_PATCH:(NSString *)URLString parameters:(id)parameters
{
    return [[self PATCH:URLString parameters:parameters success:nil failure:nil] dc_task];
}

@end

@implementation AFHTTPSessionManager (DCTask)

- (DCTask *)dc_POST:(NSString *)urlString parameters:(id)parameters
{
    return [DCTask newAsyncTask:^(DCAsyncTaskSuccess success, DCAsyncTaskFailure failure) {
        [[self POST:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(DCTaskHTTPSessionResponse(task, responseObject));
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failure(error);
        }] resume];
    }];
}

- (DCTask *)dc_POST:(NSString *)urlString parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
{
    return [DCTask newAsyncTask:^(DCAsyncTaskSuccess success, DCAsyncTaskFailure failure) {
        [[self POST:urlString parameters:parameters constructingBodyWithBlock:block success:^(NSURLSessionDataTask *task, id responseObject) {
            success(DCTaskHTTPSessionResponse(task, responseObject));
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failure(error);
        }] resume];
    }];
}

- (DCTask *)dc_GET:(NSString *)urlString parameters:(id)parameters
{
    return [DCTask newAsyncTask:^(DCAsyncTaskSuccess success, DCAsyncTaskFailure failure) {
        [[self GET:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(DCTaskHTTPSessionResponse(task, responseObject));
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failure(error);
        }] resume];
    }];
}

- (DCTask *)dc_PUT:(NSString *)urlString parameters:(id)parameters
{
    return [DCTask newAsyncTask:^(DCAsyncTaskSuccess success, DCAsyncTaskFailure failure) {
        [[self PUT:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(DCTaskHTTPSessionResponse(task, responseObject));
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failure(error);
        }] resume];
    }];
}

- (DCTask *)dc_HEAD:(NSString *)urlString parameters:(id)parameters
{
    return [DCTask newAsyncTask:^(DCAsyncTaskSuccess success, DCAsyncTaskFailure failure) {
        [[self HEAD:urlString parameters:parameters success:^(NSURLSessionDataTask *task) {
            success(DCTaskHTTPSessionResponse(task, nil));
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failure(error);
        }] resume];
    }];
}

- (DCTask *)dc_PATCH:(NSString *)urlString parameters:(id)parameters
{
    return [DCTask newAsyncTask:^(DCAsyncTaskSuccess success, DCAsyncTaskFailure failure) {
        [[self PATCH:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(DCTaskHTTPSessionResponse(task, responseObject));
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failure(error);
        }] resume];
    }];
}

- (DCTask *)dc_DELETE:(NSString *)urlString parameters:(id)parameters
{
    return [DCTask newAsyncTask:^(DCAsyncTaskSuccess success, DCAsyncTaskFailure failure) {
        [[self DELETE:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(DCTaskHTTPSessionResponse(task, responseObject));
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failure(error);
        }] resume];
    }];
}

@end

