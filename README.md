# [ZSKVOController](https://github.com/zxfcumtcs/ZSKVOController)

ZSKVOController 是一个基于 KVO 的 Data Binding 框架。

ZSKVOController 框架达到的效果：
假如：
在 ViewModel 中有属性：`title`、`desc`，
View 需要绑定`title`、`desc`，则在 View 中只需做两件事：
+ 绑定：将 ViewModel 绑定到 View 上`[_viewModel zs_addKVOObserver:self];`；
+ 通过宏`ZSKVOObserve`或`ZSKVOObserve_Change`实现 KVO 响应方法。

如：
```mm
ZSKVOObserve(title)
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

ZSKVOObserve_Change(desc, changes)
{
    _descLabel.text = changes[NSKeyValueChangeNewKey];
}
```

其中，参数：`change`由两部分组成：
+ KVO 回调方法`observeValueForKeyPath:ofObject:change:context:`中的 change；
+ 以`ZSKVONotificationKeys.observeder`为 key，observeder(ViewModel)为 value 的键值对(主要用于区分 observer 观察了多个具有相同 keypath 的 observeder)。

ZSKVOController 原理介绍请参看[简化 iOS Data Binding](https://zxfcumtcs.github.io/2016/11/05/iOSDataBinding/)
