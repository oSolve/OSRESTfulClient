//
// Created by Kros Huang on 9/12/15.
// Copyright (c) 2015 oSolve. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OSRequestErrorHandlerProtocol<NSObject>
- (NSError *)handlerError:(NSError *) error;
@end