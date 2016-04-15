//
//  OSRESTfulClientTests.m
//  OSRESTfulClientTests
//
//  Created by TC94615 on 09/23/2015.
//  Copyright (c) 2015 TC94615. All rights reserved.
//

// https://github.com/kiwi-bdd/Kiwi

#import <OSRESTfulClient/OSRESTfulEndpoint.h>

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

SPEC_END

