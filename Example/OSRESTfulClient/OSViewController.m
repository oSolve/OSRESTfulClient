//
//  OSViewController.m
//  OSRESTfulClient
//
//  Created by TC94615 on 09/23/2015.
//  Copyright (c) 2015 TC94615. All rights reserved.
//

#import <OSRESTfulClient/OSRESTfulClient.h>
#import "OSViewController.h"
#import "GithubService.h"

@interface OSViewController()

@property (nonatomic, strong) GithubService *githubService;
@end

@implementation OSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 5;
    OSRESTfulClient *client = [[OSRESTfulClient alloc] initWithQueue:operationQueue baseApiURLString:@"https://api.github.com"];
    self.githubService = [[GithubService alloc] initWithClient:client];

    [self.githubService listRepo:@"ch8908" completion:^(OSRepo *repo, NSError *error) {
        NSLog(@">>>>>>>>>>>> repo = %@", repo);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
