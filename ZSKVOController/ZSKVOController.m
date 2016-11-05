//
//  ZSKVOController.m
//  ZSKVOController
//
//  Created by zxf on 16/11/1.
//  Copyright © 2016年 zxf. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "ZSKVOController.h"
#import "ZSKVOItem.h"
#import "NSObject+ZSKVOController.h"
#import "ZSKVOControllerTool.h"

static NSString *ZSKVOControllerLockName = @"ZSKVOControllerLock";

static NSKeyValueObservingOptions ZSKVOOptions =
NSKeyValueObservingOptionNew |
NSKeyValueObservingOptionOld |
NSKeyValueObservingOptionInitial;

@interface ZSKVOController ()
{
    __weak NSObject *_observer;
    
    // key: observeder (weak reference)
    // value: KVOItem (strong reference)
    //
    NSMapTable<NSObject *, NSMutableSet<ZSKVOItem *> *> *_KVOItemsMap;
    NSRecursiveLock *_lock;
}

@end

@implementation ZSKVOController

+ (instancetype)KVOControllerWithObserver:(NSObject *)observer
{
    return [[self alloc] initWithObserver:observer];
}

- (instancetype)initWithObserver:(NSObject *)observer
{
    if (self = [super init]) {
        _observer = observer;
        
        NSPointerFunctionsOptions
        keyOptions =
        NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality,
        valueOptions =
        NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality;
        
        _KVOItemsMap =
        [[NSMapTable alloc] initWithKeyOptions:keyOptions
                                  valueOptions:valueOptions
                                      capacity:1];
        
        _lock = [[NSRecursiveLock alloc] init];
        _lock.name = ZSKVOControllerLockName;
    }
    
    return self;
}

- (void)dealloc
{
    [self unObserveAll];
}

- (ZSKVOItem *)observe:(NSObject *)observeder keyPath:(NSString *)keyPath
{
    ZSKVOItem *KVOItem =
    [ZSKVOItem KVOItemWithObserveder:observeder
                             keyPath:keyPath];
    if (!KVOItem) {
        return nil;
    }
    
    return [self observe:observeder KVOItem:KVOItem];    
}

- (NSMutableSet<ZSKVOItem *> *)observe:(NSObject *)observeder
                              keyPaths:(NSArray<NSString *> *)keyPaths
{
    NSMutableSet<ZSKVOItem *> *KVOItems =
    [[NSMutableSet alloc] initWithCapacity:keyPaths.count];
    
    [keyPaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj,
                                           NSUInteger idx,
                                           BOOL * _Nonnull stop) {
        ZSKVOItem *KVOItem = [self observe:observeder keyPath:obj];
        if (KVOItem) {
            [KVOItems addObject:KVOItem];
        }
    }];
    
    return KVOItems;
}

- (ZSKVOItem *)observe:(NSObject *)observeder KVOItem:(ZSKVOItem *)KVOItem
{
    [_lock lock];
    
    NSMutableSet<ZSKVOItem *> *KVOItems =
    [_KVOItemsMap objectForKey:observeder];
    
    if (!KVOItems) {
        // lazilly load
        //
        KVOItems = [[NSMutableSet alloc] init];
        [_KVOItemsMap setObject:KVOItems
                         forKey:observeder];
    }
    
    
    if ([KVOItems member:KVOItem]) {
        // already observe
        //
        NSLog(@"already observe %@ for %@", observeder, KVOItem.keyPath);
        
        [_lock unlock];
        return nil;
    }
    
    [KVOItems addObject:KVOItem];
    
    [_lock unlock];
    
    [observeder addObserver:self
                 forKeyPath:KVOItem.keyPath
                    options:ZSKVOOptions
                    context:(__bridge void * _Nullable)(KVOItem)];
    
    return KVOItem;
}

- (void)unObserveAll
{
    [_lock lock];
    
    NSMapTable<NSObject *, NSMutableSet<ZSKVOItem *> *> *KVOItemsMapCopy =
    [_KVOItemsMap copy];
    
    [_KVOItemsMap removeAllObjects];
    
    [_lock unlock];
    
    for (NSObject *observeder in KVOItemsMapCopy) {
        NSSet<ZSKVOItem *> *KVOItems =
        [KVOItemsMapCopy objectForKey:observeder];
        
        for (ZSKVOItem *KVOItem in KVOItems) {
            [observeder removeObserver:self
                            forKeyPath:KVOItem.keyPath
                               context:(__bridge void * _Nullable)(KVOItem)];
        }
    }
}

- (void)unObserve:(NSObject *)observeder KVOItem:(ZSKVOItem *)KVOItem
{
    [_lock lock];
    
    NSMutableSet<ZSKVOItem *> *KVOItems =
    [_KVOItemsMap objectForKey:observeder];
    
    ZSKVOItem *memberKVOItem =
    [KVOItems member:KVOItem];
    
    if (!memberKVOItem) {
        // no observer
        //
        [_lock unlock];
        
        return;
    }
    
    [KVOItems removeObject:memberKVOItem];
    
    if (KVOItems.count == 0) {
        [_KVOItemsMap removeObjectForKey:observeder];
    }
    
    [_lock unlock];
    
    [observeder removeObserver:self
                    forKeyPath:memberKVOItem.keyPath
                       context:(__bridge void * _Nullable)(memberKVOItem)];
}

- (void)unObserve:(NSObject *)observeder keyPath:(NSString *)keyPath
{
    NSAssert(observeder, @"observeder is nil!");
    
    if (!observeder) {
        return;
    }
    
    ZSKVOItem *unObserveKVOItem =
    [ZSKVOItem KVOItemWithObserveder:observeder
                             keyPath:keyPath];
    
    if (!unObserveKVOItem) {
        return;
    }
 
    [self unObserve:observeder KVOItem:unObserveKVOItem];
}

- (void)unObserve:(NSObject *)observeder keyPaths:(NSArray<NSString *> *)keyPaths
{
    [keyPaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj,
                                           NSUInteger idx,
                                           BOOL * _Nonnull stop) {
        [self unObserve:observeder keyPath:obj];
    }];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString*, id> *)change
                       context:(nullable void *)context
{
    NSAssert([((__bridge id)context) isKindOfClass:[ZSKVOItem class]], @"context is not ZSKVOItem");
    
    if (![((__bridge id)context) isKindOfClass:[ZSKVOItem class]]) {
        return;
    }
    
    ZSKVOItem *KVOItem = (__bridge id)context;
    if (!KVOItem.observeder) {
        return;
    }
    
    [_lock lock];
    
    NSSet<ZSKVOItem *> *KVOItems =
    [_KVOItemsMap objectForKey:KVOItem.observeder];
    
    if (![KVOItems member:KVOItem]) {
        [_lock unlock];
        return;
    }
    
    [_lock unlock];
    
    NSMutableDictionary<NSString *, NSObject *> *changeInfos =
    [change mutableCopy];
    
    [changeInfos setObject:KVOItem.observeder
                    forKey:ZSKVONotificationKeys.observeder];
    
    SEL selForKeyPathOfObserver =
    zs_SelForKeyPathOfObserver(keyPath, _observer);
    
    if (selForKeyPathOfObserver == NULL) {
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_observer performSelector:selForKeyPathOfObserver
                    withObject:changeInfos];
#pragma clang diagnostic pop
}

@end
