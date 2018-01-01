//
//  NSObject+ZSKVOController.h
//  ZSKVOController
//
//  Created by zxf on 16/11/1.
//  Copyright © 2016年 zxf. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ZSKVOObserveMethodPrefix zs_observe

#define ZSKVOCONCAT2(A, B) A ## B
#define ZSKVOCONCAT(A, B) ZSKVOCONCAT2(A, B)

#define ZSKVOObserve(kvo_keypath) \
- (void)ZSKVOCONCAT(ZSKVOObserveMethodPrefix, kvo_keypath):(NSDictionary *)change

#define ZSKVOObserve_Change(kvo_keypath, kvo_change) \
- (void)ZSKVOCONCAT(ZSKVOObserveMethodPrefix, kvo_keypath):(NSDictionary *)kvo_change

@interface NSObject (ZSKVOController)

- (void)zs_addKVOObserver:(NSObject *)observer;

// unless you want to unobserve
// beyond the lifecycle of the observer and observeder
// you can call zs_removeKVOObserver
//
- (void)zs_removeKVOObserver:(NSObject *)observer;

@end

// if multiple observeders have the same keypath
// you can distinction by ZSKVONotificationKeys.observeder in KVO callback
//
extern struct ZSKVONotificationKeys {
    __unsafe_unretained NSString *observeder;
} ZSKVONotificationKeys;
