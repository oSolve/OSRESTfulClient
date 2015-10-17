//
// Created by Kros Huang on 10/17/15.
// Copyright (c) 2015 TC94615. All rights reserved.
//

#import "OSRepo.h"


@implementation OSRepo
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
      @"repoId" : @"id",
      @"name" : @"name",
    };
}
@end