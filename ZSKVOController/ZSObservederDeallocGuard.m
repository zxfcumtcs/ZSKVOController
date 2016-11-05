//
//  ZSObservederDeallocGuard.m
//  ZSKVOController
//
//  Created by 赵雪峰 on 16/11/4.
//  Copyright © 2016年 zxf. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "ZSObservederDeallocGuard.h"
#import "NSObject+ZSKVOController.h"
#import "ZSKVOController.h"
#import "ZSKVOItem.h"

static NSString *ZSObservederDeallocGuardLockName = @"ZSObservederDeallocGuardLock";

@interface ZSObservederDeallocGuard ()
{
    __unsafe_unretained NSObject *_observeder;
    NSRecursiveLock *_lock;
    NSMapTable<ZSKVOController *, NSHashTable<ZSKVOItem *> *> *_observerKeyPathsMap;
}

@end

@implementation ZSObservederDeallocGuard

+ (instancetype)deallocGuardWithObserveder:(NSObject *)observeder
{
    return [[self alloc] initWithObserveder:observeder];
}

- (instancetype)initWithObserveder:(NSObject *)observeder
{
    if (self = [super init]) {
        _observeder = observeder;
        
        NSPointerFunctionsOptions
        keyOptions =
        NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality,
        valueOptions =
        NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality;

        _observerKeyPathsMap =
        [[NSMapTable alloc] initWithKeyOptions:keyOptions
                                  valueOptions:valueOptions
                                      capacity:1];
        
        _lock = [[NSRecursiveLock alloc] init];
        _lock.name = ZSObservederDeallocGuardLockName;
    }
    
    return self;
}

- (void)dealloc
{
    [self removeAllObserversOfObserveder];
}

- (void)addObserver:(ZSKVOController *)observer
        forKVOItems:(NSSet<ZSKVOItem *> *)KVOItems
{
    NSAssert(observer && KVOItems.count > 0, @"observer and keyPaths can't be nil");
    
    if (!observer || KVOItems.count == 0) {
        return;
    }
    
    [_lock lock];
    
    NSHashTable<ZSKVOItem *> *KVOItemTable =
    [_observerKeyPathsMap objectForKey:observer];

    if (!KVOItemTable) {
        NSPointerFunctionsOptions options =
        NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPersonality;
        
        KVOItemTable =
        [[NSHashTable alloc] initWithOptions:options
                                    capacity:KVOItems.count];
        
        [_observerKeyPathsMap setObject:KVOItemTable
                                 forKey:observer];
    }
    
    [KVOItems enumerateObjectsUsingBlock:^(ZSKVOItem * _Nonnull obj,
                                           BOOL * _Nonnull stop) {
        [KVOItemTable addObject:obj];
    }];

    [_lock unlock];
}

- (void)removeAllObserversOfObserveder
{    
    for (ZSKVOController *observer in _observerKeyPathsMap) {
        NSHashTable<ZSKVOItem *> *KVOItemTable =
        [_observerKeyPathsMap objectForKey:observer];
        
        for (ZSKVOItem *KVOItem in KVOItemTable) {
            [_observeder removeObserver:observer
                             forKeyPath:KVOItem.keyPath
                                context:(__bridge void * _Nullable)(KVOItem)];
        }
    }
}

@end
