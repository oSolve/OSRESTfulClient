//
// Created by Kros Huang on 10/17/15.
// Copyright (c) 2015 TC94615. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>


@interface OSRepo : MTLModel<MTLJSONSerializing>
@property (nonatomic, readonly, strong) NSNumber *repoId;
@property (nonatomic, readonly, copy) NSString *name;
@end