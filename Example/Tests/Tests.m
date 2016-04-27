//
//  OSRESTfulClientTests.m
//  OSRESTfulClientTests
//
//  Created by TC94615 on 09/23/2015.
//  Copyright (c) 2015 TC94615. All rights reserved.
//

// https://github.com/kiwi-bdd/Kiwi

#import <OSRESTfulClient/OSRESTfulEndpoint.h>
#import <OSRESTfulClient/OSRequestBuilder.h>
#import <AFNetworking/AFURLSessionManager.h>

SPEC_BEGIN(InitialTests)

    describe(@"Endpoint tests", ^{
        context(@"Base URL tests", ^{
            it(@"Init base URL", ^{
                OSRESTfulEndpoint *endpoint = [[OSRESTfulEndpoint alloc] initWithBaseURLString:@"https://api.github.com"];
                [[endpoint.baseURLString should] equal:@"https://api.github.com"];
            });
            it(@"Update base URL", ^{
                OSRESTfulEndpoint *endpoint = [[OSRESTfulEndpoint alloc] initWithBaseURLString:@"https://api.github.com"];
                [endpoint updateBaseURLString:@"https://api.github.com.tw"];
                [[endpoint.baseURLString should] equal:@"https://api.github.com.tw"];
            });
        });
    });

    describe(@"Builder tests", ^{
        context(@"Set path tests", ^{
            it(@"No parameter", ^{
                OSRESTfulEndpoint *endpoint = [[OSRESTfulEndpoint alloc] initWithBaseURLString:@"http://localhost:3000"];
                AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                OSRequestBuilder *builder = [[OSRequestBuilder alloc] initWithBaseURLString:endpoint.baseURLString
                                                                             sessionManager:manager];
                builder.setPath(@"/posts/1");
            });
            it(@"One parameter", ^{
                OSRESTfulEndpoint *endpoint = [[OSRESTfulEndpoint alloc] initWithBaseURLString:@"http://localhost:3000"];
                AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                OSRequestBuilder *builder = [[OSRequestBuilder alloc] initWithBaseURLString:endpoint.baseURLString
                                                                             sessionManager:manager];
                builder.setPath(@"/posts/{id}", @{@"id" : @"1"});
            });
            it(@"Two parameters", ^{

            });
        });
    });

SPEC_END

