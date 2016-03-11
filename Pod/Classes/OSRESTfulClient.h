//
// Created by Kros Huang on 4/17/15.
// Copyright (c) 2015 oSolve. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSRequestBuilder.h"

@interface OSRESTFulEndpoint:NSObject
@property (nonatomic, copy) NSString *baseURLString;
@end

@protocol OSRequestInterceptorProtocol;
@protocol OSRequestErrorHandlerProtocol;

@interface OSRESTfulClient : NSObject
@property (nonatomic, strong) id<OSRequestInterceptorProtocol> interceptor;
@property (nonatomic, strong) id<OSRequestErrorHandlerProtocol> errorHandler;
@property (nonatomic, assign) BOOL enableLogger;
@property (nonatomic, strong) OSRESTFulEndpoint *endpoint;

- (instancetype)initWithQueue:(NSOperationQueue *) operationQueue endpoint:(OSRESTFulEndpoint *) endpoint;

- (OSRequestBuilder *)builder;
@end