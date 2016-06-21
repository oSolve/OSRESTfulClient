//
// Created by wish8 on 3/11/16.
//

#import "OSRESTfulEndpoint.h"

@implementation OSRESTfulEndpoint
- (instancetype)initWithBaseURLString:(NSString *) baseURLString {
    self = [super init];
    if (self) {
        NSAssert(baseURLString, @"Base URL cannot be nil.");
        _baseURLString = baseURLString;
    }
    return self;
}

- (void)updateBaseURLString:(NSString *) baseURLString {
    NSAssert(baseURLString, @"Base URL cannot be nil.");
    _baseURLString = baseURLString;
}

@end