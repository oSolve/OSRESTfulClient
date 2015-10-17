//
// Created by Kros Huang on 10/17/15.
// Copyright (c) 2015 TC94615. All rights reserved.
//

#import <OSRESTfulClient/OSRESTfulClient.h>
#import <Bolts/BFTask.h>
#import "GithubService.h"
#import "OSRepo.h"


@interface GithubService()
@property (nonatomic, readonly, strong) OSRESTfulClient *client;
@end

@implementation GithubService
- (instancetype)initWithClient:(OSRESTfulClient *) client {
    self = [super init];
    if (self) {
        _client = client;
    }
    return self;
}

- (void)listRepo:(NSString *) repoName completion:(void (^)(OSRepo *, NSError *)) completion {
    BFTask *request = self.client.builder
                          .setPath(@"/users/%@/repos", repoName)
                          .withGet
                          .buildArrayWithModel([OSRepo class])
                          .request;
    [request continueWithBlock:^id(BFTask *task) {
        if (completion) {
            completion(task.result, task.error);
        }
        return nil;
    }];
}

@end