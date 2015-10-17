//
// Created by Kros Huang on 4/9/15.
// Copyright (c) 2015 oSolve. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFTask;
@protocol OSRequestErrorHandlerProtocol;
@protocol OSRequestInterceptorProtocol;

// Has No Return value
@interface OSVoidType : NSObject
@end

// Do not decode, return raw data
@interface OSRawDataType : NSObject
@end

@interface OSRequestable : NSObject
- (BFTask *)request;
@end

extern NSString *const kRequestResponseObjectKey;

@interface OSRequestBuilder : NSObject
@property (nonatomic, assign) BOOL enableLogger;
@property (nonatomic, strong) id<OSRequestInterceptorProtocol> interceptor;
@property (nonatomic, strong) id<OSRequestErrorHandlerProtocol> errorHandler;

- (instancetype)initWithQueue:(NSOperationQueue *) operationQueue baseURLString:(NSString *) baseURLString;

- (OSRequestBuilder *)withOptions;

- (OSRequestBuilder *)withGet;

- (OSRequestBuilder *)withHead;

- (OSRequestBuilder *)withPost;

- (OSRequestBuilder *)withDelete;

- (OSRequestBuilder *)withTrace;

- (OSRequestBuilder *)withConnect;

- (OSRequestBuilder *)withMultipart;

- (OSRequestBuilder *)withPut;

- (OSRequestBuilder *)withPatch;

- (OSRequestBuilder *(^)(NSString *path))withPath;

- (OSRequestBuilder *(^)(BOOL isJson))isJson;

- (OSRequestBuilder *(^)(NSDictionary *header))addHeader;

- (OSRequestBuilder *(^)(NSString *name, NSData *data))addData;

- (OSRequestBuilder *(^)(NSString *key, NSDictionary *))addMultipleData;

- (OSRequestBuilder *(^)(NSString *key, id value))addParam;

- (OSRequestBuilder *(^)(NSDictionary *params))addParams;

- (OSRequestable *(^)(Class modelCls))buildModel;

- (OSRequestable *(^)(Class modelCls))buildArrayWithModel;

- (OSRequestable *)buildVoid;

- (OSRequestable *)buildRawData;

+ (id)responseObjectFromError:(NSError *) error;

+ (NSInteger)httpStatusCodeFromError:(NSError *) error;
@end