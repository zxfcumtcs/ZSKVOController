//
//  ViewModel.h
//  Demo
//
//  Created by zxf on 16/11/4.
//  Copyright © 2016年 zxf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;

- (void)changeTitle;
- (void)changeDesc;

@end
