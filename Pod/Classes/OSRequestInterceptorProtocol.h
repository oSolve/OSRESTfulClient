//
// Created by wish8 on 7/15/15.
// Copyright (c) 2015 oSolve. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSRequestBuilder;

@protocol OSRequestInterceptorProtocol<NSObject>
- (void)intercept:(OSRequestBuilder *) builder;
@end