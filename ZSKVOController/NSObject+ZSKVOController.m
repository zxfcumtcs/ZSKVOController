//
//  NSObject+ZSKVOController.m
//  ZSKVOController
//
//  Created by zxf on 16/11/1.
//  Copyright © 2016年 zxf. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "NSObject+ZSKVOController.h"
#import "ZSKVOController.h"
#import "ZSObservederDeallocGuard.h"
#import "ZSKVOItem.h"
#import "ZSKVOControllerTool.h"

#import <objc/runtime.h>

static const void *ZSKVOControllerPropertyKey =
&ZSKVOControllerPropertyKey;

static const void *ZSKVOControllerDeallocGuardKey =
&ZSKVOControllerDeallocGuardKey;

@interface NSObject (PrivateZSKVOController)

@property (nonatomic, strong) ZSKVOController *zs_KVOController;
@property (nonatomic, strong) ZSObservederDeallocGuard *zs_observederDeallocGuard;

@end

@implementation NSObject (ZSKVOController)

- (void)zs_addKVOObserver:(NSObject *)observer
{
    NSAssert(observer, @"observer can't be nil");
    
    if (!observer) {
        return;
    }
    
    NSArray<NSString *> *observeKeyPaths =
    zs_DumpObserveKeyPaths(observer.class);
    
    if ([observeKeyPaths count] == 0) {
        return;
    }
    
    NSSet<ZSKVOItem *> *KVOItems = 
    [observer.zs_KVOController observe:self
                              keyPaths:observeKeyPaths];
    
    [self.zs_observederDeallocGuard addObserver:observer.zs_KVOController
                                    forKVOItems:KVOItems];
}


- (void)zs_removeKVOObserver:(NSObject *)observer
{
    NSAssert(observer, @"observer can't be nil");
    
    if (!observer) {
        return;
    }
    
    NSArray<NSString *> *observeKeyPaths =
    zs_DumpObserveKeyPaths(observer.class);
    
    if ([observeKeyPaths count] == 0) {
        return;
    }
    
    [observer.zs_KVOController unObserve:self
                                keyPaths:observeKeyPaths];
}

#pragma mark - KVOController Property of Observer

- (ZSKVOController *)zs_KVOController
{
    id KVOController =
    objc_getAssociatedObject(self, ZSKVOControllerPropertyKey);
    
    if (!KVOController) {
        KVOController =
        [ZSKVOController KVOControllerWithObserver:self];
        
        self.zs_KVOController = KVOController;
    }
    
    return KVOController;
}

- (void)setZs_KVOController:(ZSKVOController *)zs_KVOController
{
    objc_setAssociatedObject(self,
                             ZSKVOControllerPropertyKey,
                             zs_KVOController,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Dealloc Guard of Observeder

- (ZSObservederDeallocGuard *)zs_observederDeallocGuard
{
    id deallocGuard =
    objc_getAssociatedObject(self, ZSKVOControllerDeallocGuardKey);
    
    if (!deallocGuard) {
        deallocGuard =
        [ZSObservederDeallocGuard deallocGuardWithObserveder:self];
        
        self.zs_observederDeallocGuard = deallocGuard;
    }
    
    return deallocGuard;
}

- (void)setZs_observederDeallocGuard:(ZSObservederDeallocGuard *)zs_observederDeallocGuard
{
    objc_setAssociatedObject(self,
                             ZSKVOControllerDeallocGuardKey,
                             zs_observederDeallocGuard,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


struct ZSKVONotificationKeys ZSKVONotificationKeys = {
    .observeder = @"observeder",
};
