//
// Created by wish8 on 3/11/16.
//

#import <Foundation/Foundation.h>


@interface OSRESTfulEndpoint : NSObject
@property (nonatomic, readonly, copy) NSString *baseURLString;

- (instancetype)initWithBaseURLString:(NSString *) baseURLString;

- (void)updateBaseURLString:(NSString *) baseURLString;
@end