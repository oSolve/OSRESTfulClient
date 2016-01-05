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
    OSRESTfulClient *client = [[OSRESTfulClient alloc] initWithBaseApiURLString:@"http://localhost:3000"
                                                                  configuration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    client.enableLogger = YES;
    self.githubService = [[GithubService alloc] initWithClient:client];
    [self.githubService fetchPost:@"1" completion:^(OSRepo *repo, NSError *error) {
        NSLog(@">>>>>>>>>>>> repo = %@", repo);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
