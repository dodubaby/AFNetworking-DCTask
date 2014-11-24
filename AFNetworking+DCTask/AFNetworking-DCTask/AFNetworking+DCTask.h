//
//  AFNetworking+DCTask.h
//  Daltoniam
//
//  Created by bright on 14/11/3.
//  Copyright (c) 2014年 mtf. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <ConcurrentKit/DCTask.h>


@interface DCTaskHTTPOperationResponse : NSObject

@property (nonatomic,strong) AFHTTPRequestOperation *operation;
@property (nonatomic,strong) id responseObject;

+ (DCTaskHTTPOperationResponse *)dc_operationResponseWithOperation:(AFHTTPRequestOperation *)operation
                                                             object:(id)responseObject;

@end


@interface DCTaskHTTPSessionResponse : NSObject

@property (nonatomic,strong) NSURLSessionDataTask *task;
@property (nonatomic,strong) id responseObject;

+ (DCTaskHTTPSessionResponse *)dc_taskResponseWithTask:(NSURLSessionDataTask *)task
                                                 object:(id)responseObject;

@end


static NSString *dc_AFHTTPRequestOperationErrorKey =  @"dc_AFHTTPRequestOperationError";

@interface AFHTTPRequestOperation (DCTask)

- (DCTask *)dc_task;
- (DCTask *)dc_taskAndStartImmediately;
- (DCTask *)dc_taskByStartingImmediately:(BOOL)startImmediately;
+ (DCTask *)dc_request:(NSURLRequest *)request;
+ (DCTask *)dc_request:(NSURLRequest *)request queue:(NSOperationQueue *)queue;

@end


@interface AFHTTPRequestOperationManager (DCTask)

- (DCTask *)dc_GET:(NSString *)URLString parameters:(id)parameters;
- (DCTask *)dc_POST:(NSString *)URLString parameters:(id)parameters;
- (DCTask *)dc_POST:(NSString *)URLString parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block;
- (DCTask *)dc_PUT:(NSString *)URLString parameters:(id)parameters;
- (DCTask *)dc_DELETE:(NSString *)URLString parameters:(id)parameters;
- (DCTask *)dc_PATCH:(NSString *)URLString parameters:(id)parameters;

@end

@interface AFHTTPSessionManager (DCTask)

- (DCTask *)dc_POST:(NSString *)urlString parameters:(id)parameters;
- (DCTask *)dc_POST:(NSString *)urlString parameters:(id)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block;
- (DCTask *)dc_GET:(NSString *)urlString parameters:(id)parameters;
- (DCTask *)dc_PUT:(NSString *)urlString parameters:(id)parameters;
- (DCTask *)dc_HEAD:(NSString *)urlString parameters:(id)parameters;
- (DCTask *)dc_PATCH:(NSString *)urlString parameters:(id)parameters;
- (DCTask *)dc_DELETE:(NSString *)urlString parameters:(id)parameters;

@end
