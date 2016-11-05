//
//  ZSKVOItem.h
//  ZSKVOController
//
//  Created by zxf on 16/11/1.
//  Copyright © 2016年 zxf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSKVOItem : NSObject

+ (instancetype)KVOItemWithObserveder:(NSObject *)observeder keyPath:(NSString *)keyPath;
- (instancetype)initWithObserveder:(NSObject *)observeder keyPath:(NSString *)keyPath;

@property (nonatomic, weak, readonly) NSObject *observeder;

@property (nonatomic, strong, readonly) NSString *keyPath;

@end
