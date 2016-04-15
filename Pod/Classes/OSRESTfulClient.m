//
// Created by Kros Huang on 4/17/15.
// Copyright (c) 2015 oSolve. All rights reserved.
//

#import "OSRESTfulClient.h"
#import "OSRESTfulEndpoint.h"
#import "AFHTTPSessionManager.h"

@interface OSRESTfulClient()
@property (nonatomic, readonly, strong) OSRESTfulEndpoint *endpoint;
@property (nonatomic, strong) AFURLSessionManager *manager;
@end

@implementation OSRESTfulClient

- (void)dealloc {
    @try {
        [self.manager.operationQueue removeObserver:self forKeyPath:NSStringFromSelector(@selector(operationCount))];
    } @catch (NSException *__unused exception) {}
}

- (instancetype)initWithEndpoint:(OSRESTfulEndpoint *) endpoint configuration:(NSURLSessionConfiguration *) configuration{
    self = [super init];
    if (self) {
        NSAssert(endpoint, @"Endpoint cannot be nil.");
        _endpoint = endpoint;
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        _manager.operationQueue.maxConcurrentOperationCount = 5;
        [self.manager.operationQueue addObserver:self forKeyPath:NSStringFromSelector(@selector(operationCount))
                                                 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                                 context:nil];
    }
    return self;
}

- (OSRequestBuilder *)builder {
    OSRequestBuilder *builder = [[OSRequestBuilder alloc] initWithBaseURLString:self.endpoint.baseURLString
                                                                 sessionManager:self.manager];
    if (self.errorHandler) {
        [builder setErrorHandler:self.errorHandler];
    }
    if (self.interceptor) {
        [builder setInterceptor:self.interceptor];
    }
    [builder setEnableLogger:self.enableLogger];
    return builder;
}

- (void)observeValueForKeyPath:(NSString *) keyPath ofObject:(id) object change:(NSDictionary *) change context:(void *) context {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:[change[@"new"] intValue] > 0];
}

@end