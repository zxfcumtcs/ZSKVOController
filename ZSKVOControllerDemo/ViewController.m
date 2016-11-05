//
//  ViewController.m
//  Demo
//
//  Created by zxf on 16/11/1.
//  Copyright © 2016年 zxf. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+ZSKVOController.h"
#import "ViewModel.h"

@interface ViewController ()
{
    UILabel *_titleLabel;
    UILabel *_descLabel;
    
    UIButton *_button;
    UIButton *_button2;
    UIButton *_button3;
    UIButton *_button4;
    
    ViewModel *_viewModel;
    ViewModel *_viewModel2;
}

@end

@implementation ViewController

- (void)dealloc
{
    NSLog(@"dealloc in ViewController");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 50, 300, 50)];
    _titleLabel.font = [UIFont systemFontOfSize:18];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:_titleLabel];
    
    _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 120, 100, 50)];
    _descLabel.font = [UIFont systemFontOfSize:18];
    _descLabel.textColor = [UIColor blackColor];
    _descLabel.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:_descLabel];
    
    _button = [[UIButton alloc] initWithFrame:CGRectMake(30, 200, 150, 50)];
    [_button setTitle:@"test1" forState:UIControlStateNormal];
    _button.backgroundColor = [UIColor grayColor];
    [_button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    _button4 = [[UIButton alloc] initWithFrame:CGRectMake(200, 200, 150, 50)];
    [_button4 setTitle:@"test2" forState:UIControlStateNormal];
    _button4.backgroundColor = [UIColor grayColor];
    [_button4 addTarget:self action:@selector(btn4Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button4];
    
    _button2 = [[UIButton alloc] initWithFrame:CGRectMake(30, 350, 200, 100)];
    [_button2 setTitle:@"present" forState:UIControlStateNormal];
    _button2.backgroundColor = [UIColor greenColor];
    [_button2 addTarget:self action:@selector(btn2Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button2];
    
    _button3 = [[UIButton alloc] initWithFrame:CGRectMake(30, 500, 200, 100)];
    [_button3 setTitle:@"dismiss" forState:UIControlStateNormal];
    _button3.backgroundColor = [UIColor redColor];
    [_button3 addTarget:self action:@selector(btn3Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button3];
    
    _viewModel = [[ViewModel alloc] init];
    [_viewModel zs_addKVOObserver:self];
    
    _viewModel2 = [[ViewModel alloc] init];
    [_viewModel2 zs_addKVOObserver:self];
}


- (void)zs_observeTitle:(NSDictionary *)change
{
    if (change[ZSKVONotificationKeys.observeder] == _viewModel) {
        _titleLabel.text = [NSString stringWithFormat:@"from viewmode1：%@", change[NSKeyValueChangeNewKey]];
    }
    else if (change[ZSKVONotificationKeys.observeder] == _viewModel2) {
        _titleLabel.text = [NSString stringWithFormat:@"from viewmode2：%@", change[NSKeyValueChangeNewKey]];
    }
    else {
        _titleLabel.text = [NSString stringWithFormat:@"from unknown viewmode：%@", change[NSKeyValueChangeNewKey]];
    }
}

- (void)zs_observeDesc:(NSDictionary *)change
{
    _descLabel.text = change[NSKeyValueChangeNewKey];
}

- (void)btnClick:(id)sender
{
    [_viewModel changeTitle];
}

- (void)btn4Click:(id)sender
{
    [_viewModel2 changeTitle];
    _viewModel2 = nil;
}

- (void)btn2Click:(id)sender
{
    ViewController *viewController2 = [[ViewController alloc] init];
    [self presentViewController:viewController2 animated:YES completion:nil];
}

- (void)btn3Click:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
