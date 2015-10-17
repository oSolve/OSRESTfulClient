//
// Created by Kros Huang on 10/17/15.
// Copyright (c) 2015 TC94615. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSRepo;

@interface GithubService : NSObject
- (instancetype)initWithClient:(OSRESTfulClient *) client;

- (void)listRepo:(NSString *) repoName completion:(void (^)(OSRepo *, NSError *)) completion;
@end