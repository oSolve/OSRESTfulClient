//
// Created by Kros Huang on 4/17/15.
// Copyright (c) 2015 oSolve. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSRequestBuilder.h"

@protocol OSRequestInterceptorProtocol;
@protocol OSRequestErrorHandlerProtocol;

@interface OSRESTfulClient : NSObject
@property (nonatomic, strong) id<OSRequestInterceptorProtocol> interceptor;
@property (nonatomic, strong) id<OSRequestErrorHandlerProtocol> errorHandler;
@property (nonatomic, assign) BOOL enableLogger;

- (instancetype)initWithQueue:(NSOperationQueue *) operationQueue baseApiURLString:(NSString *) baseApiURLString;

- (OSRequestBuilder *)builder;
@end