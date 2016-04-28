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
#import <OSRESTfulClient/OSRESTfulEndpoint.h>

@interface OSViewController()

@property (nonatomic, strong) GithubService *githubService;
@end

@implementation OSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /* Use @"http://jsonplaceholder.typicode.com" instead of @"http://localhost:3000/posts"
     * since we want to observe the behavior of network activity indicator.
     * */
    OSRESTfulClient *client = [[OSRESTfulClient alloc] initWithEndpoint:[[OSRESTfulEndpoint alloc] initWithBaseURLString:@"http://jsonplaceholder.typicode.com"]
                                                          configuration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    client.enableLogger = YES;
    self.githubService = [[GithubService alloc] initWithClient:client];
    [self.githubService fetchPost:@"1" completion:^(OSRepo *repo, NSError *error) {
        NSLog(@">>>>>>>>>>>> repo = %@", repo);
    }];
    [self.githubService fetchPost:@"2" completion:^(OSRepo *repo, NSError *error) {
        NSLog(@">>>>>>>>>>>> repo = %@", repo);
    }];
    [self.githubService fetchPost:@"3" completion:^(OSRepo *repo, NSError *error) {
        NSLog(@">>>>>>>>>>>> repo = %@", repo);
    }];
    [self.githubService fetchPost:@"4" completion:^(OSRepo *repo, NSError *error) {
        NSLog(@">>>>>>>>>>>> repo = %@", repo);
    }];
    [self.githubService fetchPost:@"5" completion:^(OSRepo *repo, NSError *error) {
        NSLog(@">>>>>>>>>>>> repo = %@", repo);
    }];
    [self.githubService fetchPost:@"6" completion:^(OSRepo *repo, NSError *error) {
        NSLog(@">>>>>>>>>>>> repo = %@", repo);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end