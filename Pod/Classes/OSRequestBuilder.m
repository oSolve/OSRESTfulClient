//
// Created by Kros Huang on 4/9/15.
// Copyright (c) 2015 oSolve. All rights reserved.
//

#import <Bolts/BFTask.h>
#import "AFHTTPRequestOperation.h"
#import "MTLModel.h"
#import "MTLJSONAdapter.h"
#import "OSRequestBuilder.h"
#import "BFTaskCompletionSource.h"
#import "OSRequestErrorHandlerProtocol.h"
#import "OSRequestInterceptorProtocol.h"

NSString *const kRequestResponseObjectKey = @"kRequestResponseObjectKey";

static NSString *const MULTIPART_MIME_TYPE = @"image/jpeg";

@implementation OSVoidType
@end

@implementation OSRawDataType
@end

@interface OSRequestable()
@property (nonatomic, strong) BFTaskCompletionSource *tcs;
@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong) Class modelClass;
@property (nonatomic, assign) BOOL isArray;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, assign) BOOL isMultipart;
@property (nonatomic, assign) BOOL isJson;
@property (nonatomic, assign) BOOL enableLogger;
@property (nonatomic, strong) id<OSRequestErrorHandlerProtocol> errorHandler;
@end

@implementation OSRequestable
- (instancetype)initWithRequest:(NSURLRequest *) urlRequest modelClass:(Class) modelClass isArray:(BOOL) isArray operationQueue:(NSOperationQueue *) operationQueue isMultipart:(BOOL) isMultipart isJson:(BOOL) isJson enableLogger:(BOOL) enableLogger errorHandler:(id<OSRequestErrorHandlerProtocol>) errorHandler {
    self = [super init];
    if (self) {
        self.urlRequest = urlRequest;
        self.modelClass = modelClass;
        self.isArray = isArray;
        self.operationQueue = operationQueue;
        self.isMultipart = isMultipart;
        self.isJson = isJson;
        self.enableLogger = enableLogger;
        self.errorHandler = errorHandler;
    }
    return self;
}

- (BFTask *)request {
    _tcs = [BFTaskCompletionSource taskCompletionSource];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:self.urlRequest];
    if (self.isMultipart) {
        [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long int totalBytesWritten, long long int totalBytesExpectedToWrite) {
            // TODO - pass out progress
        }];
    }
    if (self.isJson) {
        requestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    } else {
        requestOperation.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    [requestOperation.responseSerializer setStringEncoding:NSUTF8StringEncoding];
    [requestOperation
      setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (self.enableLogger) {
              NSLog(@"Request Builder Success:%@, URL:%@, Body:%@, Model:%@, responseObject:%@", self.urlRequest.HTTPMethod, [self.urlRequest URL], [self convertHttpBodyToString:self.urlRequest.HTTPBody], self.modelClass, responseObject);
          }
          [_tcs setResult:[self decodeResponseObject:responseObject]];
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        id data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        NSString *errorMessage = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        if (self.enableLogger) {
            NSLog(@"Request Builder Failed:%@, URL:%@, Body:%@, Model:%@, Error:%@", self.urlRequest.HTTPMethod, [self.urlRequest URL], [self convertHttpBodyToString:self.urlRequest.HTTPBody], self.modelClass, error);
            NSLog(@"decode error message:%@", errorMessage);
        }
        NSError *patchedError = [self getPatchedError:operation.responseObject error:error];
        if (self.errorHandler) {
            [_tcs setError:[self.errorHandler handlerError:patchedError]];
        } else {
            [_tcs setError:patchedError];
        }
    }];
    [self.operationQueue addOperation:requestOperation];
    return self.tcs.task;
}

- (NSError *)getPatchedError:(id) responseObject error:(NSError *) error {
    NSMutableDictionary *patchedUserInfo = [error.userInfo mutableCopy];
    if (responseObject) {
        patchedUserInfo[kRequestResponseObjectKey] = responseObject;
    }
    NSError *patchedError = [NSError errorWithDomain:error.domain
                                                code:error.code
                                            userInfo:[patchedUserInfo copy]];
    return patchedError;
}

- (NSString *)convertHttpBodyToString:(NSData *) body {
    return [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
}

- (id)decodeResponseObject:(id) responseObject {
    if ([self.modelClass isSubclassOfClass:[OSVoidType class]]) {
        return nil;
    }

    if ([self.modelClass isSubclassOfClass:[OSRawDataType class]]) {
        return responseObject;
    }

    if (![self.modelClass isSubclassOfClass:[MTLModel class]]) {
        NSAssert(false, @"model class must be one of OSVoidType, OSRawDataType or subclass of MTLModel");
    }

    if (self.isArray) {
        NSAssert([responseObject isKindOfClass:[NSArray class]], @"Decode failed, result should be array.");
        return [MTLJSONAdapter modelsOfClass:self.modelClass fromJSONArray:responseObject error:nil];
    } else {
        NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"Decode failed, result should be dictionary");
        return [MTLJSONAdapter modelOfClass:self.modelClass fromJSONDictionary:responseObject error:nil];
    }
}

@end

@interface OSRequestBuilder()
@property (nonatomic, copy) NSString *baseUrlString;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, strong) Class modelClass;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableDictionary *header;
@property (nonatomic, strong) NSDictionary *multipartData;
@property (nonatomic, assign) BOOL isMultipart;
@property (nonatomic, assign) BOOL isJsonFormat;
@property (nonatomic, copy) NSString *multipartFileKey;
@end

@implementation OSRequestBuilder

- (instancetype)initWithQueue:(NSOperationQueue *) operationQueue baseURLString:(NSString *) baseURLString {
    self = [super init];
    if (self) {
        _operationQueue = operationQueue;
        _baseUrlString = baseURLString;
        _isJsonFormat = YES;
    }
    return self;
}

- (OSRequestBuilder *)withOptions {
    self.method = @"OPTIONS";
    return self;
}

- (OSRequestBuilder *)withGet {
    self.method = @"GET";
    return self;
}

- (OSRequestBuilder *)withHead {
    self.method = @"HEAD";
    return self;
}

- (OSRequestBuilder *)withPost {
    self.method = @"POST";
    return self;
}

- (OSRequestBuilder *)withPut {
    self.method = @"PUT";
    return self;
}

- (OSRequestBuilder *)withPatch {
    self.method = @"PATCH";
    return self;
}

- (OSRequestBuilder *)withDelete {
    self.method = @"DELETE";
    return self;
}

- (OSRequestBuilder *)withTrace {
    self.method = @"TRACE";
    return self;
}

- (OSRequestBuilder *)withConnect {
    self.method = @"CONNECT";
    return self;
}

- (OSRequestBuilder *)withMultipart {
    self.isMultipart = YES;
    return self;
}

- (OSRequestBuilder *)withPath:(NSString *) path {
    NSAssert([path characterAtIndex:0] == '/', @"path must be start with '/'");
    self.path = path;
    return self;
}

- (OSRequestBuilder *)addParam:(NSString *) key value:(NSString *) value {
    NSAssert(key, @"param key can not be nil");
    NSAssert(value, @"param value can not be nil");
    if (!self.params) {
        self.params = [NSMutableDictionary dictionary];
    }
    self.params[key] = value;
    return self;
}

- (OSRequestBuilder *)addParams:(NSDictionary *) params {
    NSAssert(params, @"add params can not be nil");
    if (!self.params) {
        self.params = [NSMutableDictionary dictionary];
    }
    [self.params addEntriesFromDictionary:params];
    return self;
}

- (OSRequestBuilder *)addHeader:(NSDictionary *) header {
    if (!self.header) {
        self.header = [NSMutableDictionary dictionary];
    }
    [self.header addEntriesFromDictionary:header];
    return self;
}

- (OSRequestable *)buildModel:(Class) modelClass {
    return [self buildWithModel:modelClass isArray:NO];
}

- (OSRequestable *)buildModels:(Class) modelClass {
    return [self buildWithModel:modelClass isArray:YES];
}

- (OSRequestBuilder *(^)(NSDictionary *header))addHeader {
    return ^OSRequestBuilder *(NSDictionary *header) {
        if (!self.header) {
            self.header = [NSMutableDictionary dictionary];
        }
        [self.header addEntriesFromDictionary:header];
        return self;
    };
}

- (OSRequestBuilder *(^)(NSString *name, NSData *data))addData {
    return ^OSRequestBuilder *(NSString *name, NSData *data) {
        self.multipartData = @{name : data};
        return self;
    };
}

- (OSRequestBuilder *(^)(NSString *, NSDictionary *))addMultipleData {
    return ^OSRequestBuilder *(NSString *key, NSDictionary *multipleData) {
        self.multipartFileKey = key;
        if (self.multipartData) {
            NSMutableDictionary *mutableDictionary = [self.multipartData mutableCopy];
            [mutableDictionary addEntriesFromDictionary:multipleData];
            self.multipartData = [mutableDictionary copy];
        } else {
            self.multipartData = [multipleData copy];
        }
        return self;
    };
}

- (OSRequestBuilder *(^)(NSString *key, id value))addParam {
    return ^OSRequestBuilder *(NSString *key, NSString *value) {
        NSAssert(key, @"param key can not be nil");
        NSAssert(value, @"param value can not be nil");
        if (!self.params) {
            self.params = [NSMutableDictionary dictionary];
        }
        self.params[key] = value;
        return self;
    };
}

- (OSRequestBuilder *(^)(NSDictionary *params))addParams {
    return ^OSRequestBuilder *(NSDictionary *params) {
        NSAssert(params, @"add params can not be nil");
        if (!self.params) {
            self.params = [NSMutableDictionary dictionary];
        }
        [self.params addEntriesFromDictionary:params];
        return self;
    };
}

- (OSRequestBuilder *(^)(NSString *format, ...))setPath {
    return ^OSRequestBuilder *(NSString *format, ...) {
        NSAssert([format characterAtIndex:0] == '/', @"path must be start with '/'");
        NSString *path;
        va_list vl;
        va_start(vl, format);
        path = [[NSString alloc] initWithFormat:format arguments:vl];
        va_end(vl);
        self.path = path;
        return self;
    };
}

- (OSRequestBuilder *(^)(BOOL isJson))isJson {
    return ^OSRequestBuilder *(BOOL isJson) {
        self.isJsonFormat = isJson;
        return self;
    };
}

- (OSRequestable *(^)(Class modelCls))buildModel {
    return ^OSRequestable *(Class modelCls) {
        NSAssert(![modelCls isSubclassOfClass:[OSVoidType class]], @"Return void should using [buildVoid] method.");
        NSAssert(![modelCls isSubclassOfClass:[OSRawDataType class]], @"Return should using [buildRawData] method.");
        return [self buildWithModel:modelCls isArray:NO];
    };
}

- (OSRequestable *(^)(Class modelCls))buildArrayWithModel {
    return ^OSRequestable *(Class modelCls) {
        NSAssert(![modelCls isSubclassOfClass:[OSVoidType class]], @"Void return should using [buildVoid] method.");
        NSAssert(![modelCls isSubclassOfClass:[OSRawDataType class]], @"Return should using [buildRawData] method.");
        return [self buildWithModel:modelCls isArray:YES];
    };
}

- (OSRequestable *)buildVoid {
    return [self buildWithModel:[OSVoidType class] isArray:NO];
}

- (OSRequestable *)buildRawData {
    return [self buildWithModel:[OSRawDataType class] isArray:NO];
}

- (OSRequestable *)buildWithModel:(Class) modelClass isArray:(BOOL) isArray {
    self.modelClass = modelClass;

    NSAssert(self.path, @"path cannot be nil");
    NSAssert(self.method, @"method cannot be nil");
    NSAssert(self.modelClass, @"model class cannot be nil");

    if (self.interceptor) {
        [self.interceptor intercept:self];
    }

    NSString *escapedPath = [self.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request;
    if (self.isMultipart) {
        __weak typeof(self) weakSelf = self;
        NSAssert(self.multipartData, @"multipart upload, multipart data cannot be nil");
        request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:self.method
                                                                             URLString:[self requestURL:escapedPath]
                                                                            parameters:self.params
                                                             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                 [weakSelf appendMultipartData:formData];
                                                             } error:nil];
    } else {
        request = [[AFHTTPRequestSerializer serializer] requestWithMethod:self.method
                                                                URLString:[self requestURL:escapedPath]
                                                               parameters:self.params
                                                                    error:nil];
    }
    [self insertHeaderToRequest:request];
    return [[OSRequestable alloc] initWithRequest:request modelClass:self.modelClass isArray:isArray operationQueue:self.operationQueue isMultipart:self.isMultipart isJson:self.isJsonFormat enableLogger:self.enableLogger errorHandler:self.errorHandler];
}

- (void)appendMultipartData:(id<AFMultipartFormData>) formData {
    for (int i = 0; i < self.multipartData.allKeys.count; ++i) {
        id key = self.multipartData.allKeys[i];
        [formData appendPartWithFileData:self.multipartData[key]
                                    name:self.multipartFileKey ?: key
                                fileName:[NSString stringWithFormat:@"%@.png", key]
                                mimeType:MULTIPART_MIME_TYPE];
    }
}

- (void)insertHeaderToRequest:(NSMutableURLRequest *) request {
    if (self.header) {
        for (NSString *key in self.header.allKeys) {
            [request addValue:key forHTTPHeaderField:self.header[key]];
        }
    }
}

- (NSString *)requestURL:(NSString *) path {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", self.baseUrlString, path];
    return URLString;
}

+ (id)responseObjectFromError:(NSError *) error {
    return error.userInfo[kRequestResponseObjectKey];
}

+ (NSInteger)httpStatusCodeFromError:(NSError *) error {
    return [error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
}
@end
