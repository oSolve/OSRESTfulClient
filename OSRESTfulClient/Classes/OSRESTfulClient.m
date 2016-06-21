//
// Created by Kros Huang on 4/17/15.
// Copyright (c) 2015 oSolve. All rights reserved.
//

#import "OSRESTfulClient.h"
#import "OSRESTfulEndpoint.h"
#import "AFHTTPSessionManager.h"
#import "AFNetworkActivityIndicatorManager.h"

@interface OSRESTfulClient()
@property (nonatomic, readonly, strong) OSRESTfulEndpoint *endpoint;
@property (nonatomic, strong) AFURLSessionManager *manager;
@end

@implementation OSRESTfulClient

- (instancetype)initWithEndpoint:(OSRESTfulEndpoint *) endpoint configuration:(NSURLSessionConfiguration *) configuration {
    self = [super init];
    if (self) {
        NSAssert(endpoint, @"Endpoint cannot be nil.");
        _endpoint = endpoint;
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        _manager.operationQueue.maxConcurrentOperationCount = 5;
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

- (OSRequestBuilder *)builder {
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    OSRequestBuilder *builder = [[OSRequestBuilder alloc] initWithBaseURLString:self.endpoint.baseURLString
                                                                 sessionManager:self.manager
                                                                 terminate:^{
                                                                     [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                                                                 }];
    if (self.errorHandler) {
        [builder setErrorHandler:self.errorHandler];
    }
    if (self.interceptor) {
        [builder setInterceptor:self.interceptor];
    }
    [builder setEnableLogger:self.enableLogger];
    return builder;
}

@end