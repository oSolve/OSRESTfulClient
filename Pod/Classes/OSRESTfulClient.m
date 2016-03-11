//
// Created by Kros Huang on 4/17/15.
// Copyright (c) 2015 oSolve. All rights reserved.
//

#import "OSRESTfulClient.h"
#import <UIKit/UIKit.h>

@interface OSRESTfulClient()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@end

@implementation OSRESTfulClient

- (void)dealloc {
    @try {
        [_operationQueue removeObserver:self forKeyPath:NSStringFromSelector(@selector(operationCount))];
    } @catch (NSException *__unused exception) {}
}

- (instancetype)initWithQueue:(NSOperationQueue *) operationQueue endpoint:(OSRESTFulEndpoint *) endpoint {
    self = [super init];
    if (self) {
        self.operationQueue = operationQueue;
        self.endpoint = endpoint;
        [_operationQueue addObserver:self forKeyPath:NSStringFromSelector(@selector(operationCount))
                             options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (OSRequestBuilder *)builder {
    OSRequestBuilder *builder = [[OSRequestBuilder alloc] initWithQueue:self.operationQueue
                                                          baseURLString:self.endpoint.baseURLString];
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