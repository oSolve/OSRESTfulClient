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
#import "AFHTTPSessionManager.h"

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
@property (nonatomic, assign) BOOL isMultipart;
@property (nonatomic, assign) BOOL isJson;
@property (nonatomic, assign) BOOL enableLogger;
@property (nonatomic, strong) id<OSRequestErrorHandlerProtocol> errorHandler;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, copy) void (^terminate)();
@end

@implementation OSRequestable
- (instancetype)initWithRequest:(NSURLRequest *) urlRequest modelClass:(Class) modelClass isArray:(BOOL) isArray isMultipart:(BOOL) isMultipart isJson:(BOOL) isJson enableLogger:(BOOL) enableLogger errorHandler:(id<OSRequestErrorHandlerProtocol>) errorHandler sessionManager:(AFURLSessionManager *) sessionManager terminate:(void (^)()) terminate {
    self = [super init];
    if (self) {
        self.urlRequest = urlRequest;
        self.modelClass = modelClass;
        self.isArray = isArray;
        self.isMultipart = isMultipart;
        self.isJson = isJson;
        self.enableLogger = enableLogger;
        self.errorHandler = errorHandler;
        self.sessionManager = sessionManager;
        self.terminate = terminate;
    }
    return self;
}

- (BFTask *)request {
    _tcs = [BFTaskCompletionSource taskCompletionSource];
    if (self.enableLogger) {
        NSLog(@"Making Request With Builder:%@, URL:%@, Body:%@, Model:%@", self.urlRequest.HTTPMethod, [self.urlRequest URL], [self convertHttpBodyToString:self.urlRequest.HTTPBody], self.modelClass);
    }

    NSURLSessionDataTask *task;
    if (self.isMultipart) {
        [self.sessionManager uploadTaskWithRequest:self.urlRequest fromData:nil
                                          progress:NULL
                                 completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                     [self handleResponse:responseObject error:error];
                                 }];
    } else {
        task = [self.sessionManager dataTaskWithRequest:self.urlRequest
                                      completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                                          [self handleResponse:responseObject error:error];
                                      }];
    }
    [task resume];
    return self.tcs.task;
}

- (void)handleResponse:(id) responseObject error:(NSError *) error {
    if (error) {
        id data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        NSString *errorMessage = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        if (self.enableLogger) {
            NSLog(@"Request Builder Failed:%@, URL:%@, Body:%@, Model:%@, Error:%@", self.urlRequest.HTTPMethod, [self.urlRequest URL], [self convertHttpBodyToString:self.urlRequest.HTTPBody], self.modelClass, error);
            NSLog(@"Decoded response error message:%@", errorMessage);
        }
        NSError *patchedError = [self getPatchedError:responseObject
                                                error:error];
        if (self.errorHandler) {
            [_tcs setError:[self.errorHandler handlerError:patchedError]];
        } else {
            [_tcs setError:patchedError];
        }
    } else {
        if (self.enableLogger) {
            NSLog(@"Request Builder Success:%@, URL:%@, Body:%@, Model:%@, responseObject:%@", self.urlRequest.HTTPMethod, [self.urlRequest URL], [self convertHttpBodyToString:self.urlRequest.HTTPBody], self.modelClass, responseObject);
        }
        [_tcs setResult:[self decodeResponseObject:responseObject]];
    }
    self.terminate();
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
        NSAssert(false, @"Model class must be one of OSVoidType, OSRawDataType or subclass of MTLModel");
    }

    if (self.isArray) {
        NSAssert([responseObject isKindOfClass:[NSArray class]], @"Model Decode failed, result should be array.");
        NSError *error = nil;
        NSArray *array = [MTLJSONAdapter modelsOfClass:self.modelClass fromJSONArray:responseObject error:&error];
        if (self.enableLogger && error) {
            NSLog(@"Model decode failed, error message:%@", error);
        }
        return array;
    } else {
        NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"Model Decode failed, result should be dictionary");
        NSError *error = nil;
        id object = [MTLJSONAdapter modelOfClass:self.modelClass fromJSONDictionary:responseObject error:&error];
        if (self.enableLogger && error) {
            NSLog(@"Model decode failed, error message:%@", error);
        }
        return object;
    }
}

@end

@interface OSRequestBuilder()
@property (nonatomic, copy) NSString *baseUrlString;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, strong) Class modelClass;
@property (nonatomic, strong) NSMutableDictionary *header;
@property (nonatomic, strong) NSDictionary *multipartData;
@property (nonatomic, assign) BOOL isMultipart;
@property (nonatomic, assign) BOOL isJsonFormat;
@property (nonatomic, copy) NSString *multipartFileKey;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, copy) void (^terminate)();
@end

@implementation OSRequestBuilder

- (instancetype)initWithBaseURLString:(NSString *) baseURLString sessionManager:(AFURLSessionManager *) sessionManager terminate:(void (^)()) terminate {
    self = [super init];
    if (self) {
        _baseUrlString = baseURLString;
        _sessionManager = sessionManager;
        _isJsonFormat = YES;
        _terminate = terminate;
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

- (OSRequestBuilder *(^)(NSString *path))setPath {
    return ^OSRequestBuilder *(NSString *path) {
        NSAssert([path characterAtIndex:0] == '/', @"path must be start with '/'");
        _path = path;
        return self;
    };
}

- (OSRequestBuilder *(^)(NSString *path, NSDictionary *params))setPathAndParams {
    return ^OSRequestBuilder *(NSString *path, NSDictionary *mappers) {
        NSAssert([path characterAtIndex:0] == '/', @"path must be start with '/'");
        if (mappers) {
            for (NSString *key in mappers) {
                NSString *pattern = [NSString stringWithFormat:@"{%@}", key];
                path = [path stringByReplacingOccurrencesOfString:pattern
                                                       withString:mappers[key]];
            }
        }
        _path = path;
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
    NSString *escapedPath = [self.path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
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
    return [[OSRequestable alloc] initWithRequest:request
                                       modelClass:self.modelClass
                                          isArray:isArray
                                      isMultipart:self.isMultipart
                                           isJson:self.isJsonFormat
                                     enableLogger:self.enableLogger
                                     errorHandler:self.errorHandler
                                   sessionManager:self.sessionManager
                                        terminate:self.terminate];
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
