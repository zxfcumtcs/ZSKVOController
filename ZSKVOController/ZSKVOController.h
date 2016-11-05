//
//  ZSKVOController.h
//  ZSKVOController
//
//  Created by zxf on 16/11/1.
//  Copyright © 2016年 zxf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZSKVOItem;

@interface ZSKVOController : NSObject

- (instancetype)initWithObserver:(NSObject *)observer;
+ (instancetype)KVOControllerWithObserver:(NSObject *)observer;

- (ZSKVOItem *)observe:(NSObject *)observeder keyPath:(NSString *)keyPath;
- (NSMutableSet<ZSKVOItem *> *)observe:(NSObject *)observeder keyPaths:(NSArray<NSString *> *)keyPaths;

- (void)unObserve:(NSObject *)observeder keyPath:(NSString *)keyPath;
- (void)unObserve:(NSObject *)observeder keyPaths:(NSArray<NSString *> *)keyPaths;

- (void)unObserve:(NSObject *)observeder KVOItem:(ZSKVOItem *)KVOItem;

@end
