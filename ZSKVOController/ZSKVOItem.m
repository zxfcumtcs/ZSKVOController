//
//  ZSKVOItem.m
//  ZSKVOController
//
//  Created by zxf on 16/11/1.
//  Copyright © 2016年 zxf. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "ZSKVOItem.h"
#import "ZSKVOControllerTool.h"

@implementation ZSKVOItem

+ (instancetype)KVOItemWithObserveder:(NSObject *)observeder
                              keyPath:(NSString *)keyPath
{
    NSAssert(observeder && keyPath, @"observeder and keyPath can't be nil");
    
    if (!observeder || !keyPath) {
        return nil;
    }
    
    return [[self alloc] initWithObserveder:observeder
                                    keyPath:keyPath];
}

- (instancetype)initWithObserveder:(NSObject *)observeder
                           keyPath:(NSString *)keyPath
{
    NSString *originalKeyPath =
    zs_KeyPathOfObserveder(keyPath, observeder);
    
    if (!originalKeyPath) {
        NSLog(@"%@ has not keyPath: %@", observeder, keyPath);
        
        return nil;
    }
    
    if (self = [super init]) {
        _observeder = observeder;
        _keyPath = originalKeyPath;
    }
    
    return self;
}

- (NSUInteger)hash
{
    return [self.keyPath hash];
}

- (BOOL)isEqual:(NSObject *)object
{
    if (!object || ![object isKindOfClass:self.class]) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    return [self.keyPath isEqualToString:((ZSKVOItem *)object).keyPath];
}

@end
