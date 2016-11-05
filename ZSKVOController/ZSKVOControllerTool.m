//
//  ZSKVOControllerTool.m
//  Demo
//
//  Created by zxf on 16/11/5.
//  Copyright © 2016年 zxf. All rights reserved.
//

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "ZSKVOControllerTool.h"
#import <objc/runtime.h>


static NSString *ZSKVOObserveMethodPrefix =
@"zs_observe";

NSArray<NSString *>* zs_DumpObjcMethods(Class clz)
{
    unsigned int methodCount = 0;

    Method *methods =
    class_copyMethodList(clz, &methodCount);

    NSMutableArray<NSString *> *methodNames =
    [NSMutableArray arrayWithCapacity:methodCount];

    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        
        NSString *methodName =
        NSStringFromSelector(method_getName(method));
        
        if (methodName) {
            [methodNames addObject:methodName];
        }
    }

    free(methods);

    return [methodNames copy];
}

NSString* zs_RegexObserveKeyPath(NSString *methodName)
{
    if (!methodName) {
        return nil;
    }
    
    NSString *pattern =
    [NSString stringWithFormat:@"(^%@){1}?([a-zA-Z0-9_]{1,})?([:]{1}$)",
     ZSKVOObserveMethodPrefix];
    NSError  *error = nil;
    NSRegularExpression *regex =
    [NSRegularExpression regularExpressionWithPattern:pattern
                                              options:0
                                                error:&error];
    
    if (error) {
        return nil;
    }
    
    NSArray *matches =
    [regex matchesInString:methodName
                   options:0
                     range:NSMakeRange(0, methodName.length)];
    
    if (matches.count < 1) {
        return nil;
    }
    
    NSTextCheckingResult *chechingResult = [matches objectAtIndex:0];
    if (chechingResult.numberOfRanges < 4) {
        return nil;
    }
    
    return [methodName substringWithRange:[chechingResult rangeAtIndex:2]];
}

NSArray<NSString *>* zs_DumpObserveKeyPaths(Class clz)
{
    NSMutableArray<NSString *> *observeKeypahts = [NSMutableArray array];
    
    NSArray<NSString *> *methodNames = zs_DumpObjcMethods(clz);
    [methodNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj,
                                              NSUInteger idx,
                                              BOOL * _Nonnull stop) {
        NSString *keyPath = zs_RegexObserveKeyPath(obj);
        if (keyPath.length > 0) {
            [observeKeypahts addObject:keyPath];
        }
    }];
    
    return [observeKeypahts copy];
}

NSString *zs_KeyPathOfObserveder(NSString *keyPath, NSObject *observeder)
{
    if (!observeder || !keyPath) {
        return nil;
    }
    
    NSArray<NSString *> *methodsOfObserveder =
    zs_DumpObjcMethods(observeder.class);
    
    __block NSString *originalKeyPath = nil;
    [methodsOfObserveder enumerateObjectsUsingBlock:^(NSString * _Nonnull obj,
                                                      NSUInteger idx,
                                                      BOOL * _Nonnull stop) {
        if ([obj isEqualToString:keyPath] ||
            [obj isEqualToString:zs_lowercaseInitials(keyPath)]) {
            originalKeyPath = obj;
            *stop = YES;
        }
    }];
    
    return originalKeyPath;
}

NSString *zs_handleInitials(NSString *originalStr, BOOL uppercase)
{
    if (originalStr.length == 0) {
        return nil;
    }
    
    NSString *firstCapChar = uppercase ?
    [[originalStr substringToIndex:1] uppercaseString] :
    [[originalStr substringToIndex:1] lowercaseString];
    
    NSString *lowercaseString =
    [originalStr stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                         withString:firstCapChar];
    
    return lowercaseString;
}

NSString *zs_uppercaseInitials(NSString *originalStr)
{
    return zs_handleInitials(originalStr, YES);
}

NSString *zs_lowercaseInitials(NSString *originalStr)
{
    return zs_handleInitials(originalStr, NO);
}

SEL zs_SelForKeyPathOfObserver(NSString *keyPath, NSObject *observer)
{
    if (keyPath.length == 0 || !observer) {
        return NULL;
    }
    
    NSString *selName = [NSString stringWithFormat:@"%@%@:",
                         ZSKVOObserveMethodPrefix,
                         zs_uppercaseInitials(keyPath)];
    
    SEL sel = NSSelectorFromString(selName);
    
    if ([observer respondsToSelector:sel]) {
        return sel;
    }
    
    return NULL;
}