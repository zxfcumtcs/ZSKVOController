//
//  ZSObservederDeallocGuard.h
//  ZSKVOController
//
//  Created by 赵雪峰 on 16/11/4.
//  Copyright © 2016年 zxf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZSKVOItem;
@class ZSKVOController;

@interface ZSObservederDeallocGuard : NSObject

+ (instancetype)deallocGuardWithObserveder:(NSObject *)observeder;
- (instancetype)initWithObserveder:(NSObject *)observeder;

- (void)addObserver:(ZSKVOController *)observer
        forKVOItems:(NSSet<ZSKVOItem *> *)KVOItems;

@end
