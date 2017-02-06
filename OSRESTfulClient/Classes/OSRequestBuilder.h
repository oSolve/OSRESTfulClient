//
// Created by Kros Huang on 4/9/15.
// Copyright (c) 2015 oSolve. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OSRequestErrorHandlerProtocol;
@protocol OSRequestInterceptorProtocol;
@class BFTask;
@class AFURLSessionManager;

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
@property (nonatomic, readonly, copy) NSString *path;

- (instancetype)initWithBaseURLString:(NSString *) baseURLString sessionManager:(AFURLSessionManager *) sessionManager terminate:(void (^)()) terminate;

- (OSRequestBuilder *)withOptions;

- (OSRequestBuilder *)withGet;

- (OSRequestBuilder *)withHead;

- (OSRequestBuilder *)withPost;

- (OSRequestBuilder *)withDelete;

- (OSRequestBuilder *)withTrace;

- (OSRequestBuilder *)withConnect;

- (OSRequestBuilder *)withPut;

- (OSRequestBuilder *)withPatch;

- (OSRequestBuilder *(^)(NSString *path))setPath;

- (OSRequestBuilder *(^)(NSDictionary *params))setPathParams;

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