//
//  ViewModel.m
//  Demo
//
//  Created by zxf on 16/11/4.
//  Copyright © 2016年 zxf. All rights reserved.
//

#import "ViewModel.h"

@implementation ViewModel

- (instancetype)init
{
    if (self = [super init]) {
        _title = @"Test";
        _desc = @"desc";
    }
    
    return self;
}

- (void)changeTitle
{
    self.title = @"changeTitle";
}

- (void)changeDesc
{
    self.desc = @"changeDesc";
}

@end
