//
//  ZSKVOControllerTool.h
//  Demo
//
//  Created by zxf on 16/11/5.
//  Copyright © 2016年 zxf. All rights reserved.
//

#import <Foundation/Foundation.h>

NSArray<NSString *>* zs_DumpObjcMethods(Class clz);
NSString* zs_RegexObserveKeyPath(NSString *methodName);
NSArray<NSString *>* zs_DumpObserveKeyPaths(Class clz);
NSString *zs_uppercaseInitials(NSString *originalStr);
NSString *zs_lowercaseInitials(NSString *originalStr);

NSString *zs_KeyPathOfObserveder(NSString *keyPath, NSObject *observeder);

SEL zs_SelForKeyPathOfObserver(NSString *keyPath, NSObject *observer);
