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
                OSRequestBuilder *builder = [[OSRequestBuilder alloc] initWithBaseURLString:@""
                                                                             sessionManager:[AFURLSessionManager mock]
                                                                                  terminate:nil];
                builder.setPath(@"/posts/", nil);
                [[builder.path should] equal:@"/posts/"];
            });
            it(@"One parameter", ^{
                OSRequestBuilder *builder = [[OSRequestBuilder alloc] initWithBaseURLString:@""
                                                                             sessionManager:[AFURLSessionManager mock]
                                                                                  terminate:nil];
                builder.setPath(@"/posts/{id}", @{@"id" : @"1"});
                [[builder.path should] equal:@"/posts/1"];
            });
            it(@"No parameter but one argument", ^{
                OSRequestBuilder *builder = [[OSRequestBuilder alloc] initWithBaseURLString:@""
                                                                             sessionManager:[AFURLSessionManager mock]
                                                                                  terminate:nil];
                builder.setPath(@"/posts/{id}", nil);
                [[builder.path should] equal:@"/posts/{id}"];
            });
            it(@"Two parameters", ^{
                OSRequestBuilder *builder = [[OSRequestBuilder alloc] initWithBaseURLString:@""
                                                                             sessionManager:[AFURLSessionManager mock]
                                                                                  terminate:nil];
                builder.setPath(@"/posts/{id}/{sid}.json", @{@"id" : @"1", @"sid" : @"aaa"});
                [[builder.path should] equal:@"/posts/1/aaa.json"];
            });
            it(@"One parameters but two arguments", ^{
                OSRequestBuilder *builder = [[OSRequestBuilder alloc] initWithBaseURLString:@""
                                                                             sessionManager:[AFURLSessionManager mock]
                                                                                  terminate:nil];
                builder.setPath(@"/posts/{id}/{sid}.json", @{@"id" : @"1"});
                [[builder.path should] equal:@"/posts/1/{sid}.json"];
            });
            it(@"Two parameters, one of that is incorrect pattern", ^{
                OSRequestBuilder *builder = [[OSRequestBuilder alloc] initWithBaseURLString:@""
                                                                             sessionManager:[AFURLSessionManager mock]
                                                                                  terminate:nil];
                builder.setPath(@"/posts/{id}/{sid}.json", @{@"id" : @"1", @"sLd" : @"aaa"});
                [[builder.path should] equal:@"/posts/1/{sid}.json"];
            });
            it(@"Three parameters but two arguments", ^{
                OSRequestBuilder *builder = [[OSRequestBuilder alloc] initWithBaseURLString:@""
                                                                             sessionManager:[AFURLSessionManager mock]
                                                                                  terminate:nil];
                builder.setPath(@"/posts/{id}/{sid}.json", @{@"id" : @"1", @"sid" : @"aaa", @"tid" : @"a1a1"});
                [[builder.path should] equal:@"/posts/1/aaa.json"];
            });
        });
    });

SPEC_END

