# [ZSKVOController](https://github.com/zxfcumtcs/ZSKVOController)

ZSKVOController 是一个基于 KVO 的 Data Binding 框架。

ZSKVOController 框架达到的效果：
假如：
在 ViewModel 中有属性：`title`、`desc`，
View 需要绑定`title`、`desc`，则在 View 中只需做两件事：
+ 绑定：将 ViewModel 绑定到 View 上`[_viewModel zs_addKVOObserver:self];`；
+ 实现方法：`zs_observeTitle:`、`zs_observeDesc:`。

其中，`zs_observeDesc:`的实现可能如下：
```
- (void)zs_observeDesc:(NSDictionary *)change
{
    _descLabel.text = change[NSKeyValueChangeNewKey];
}
```

其中，参数：`change`由两部分组成：
+ KVO 回调方法`observeValueForKeyPath:ofObject:change:context:`中的 change；
+ 以`ZSKVONotificationKeys.observeder`为 key，observeder(ViewModel)为 value 的键值对(主要用于区分 observer 观察了多个具有相同 keypath 的 observeder)。

ZSKVOController 原理介绍请参看[简化 iOS Data Binding](https://zxfcumtcs.github.io/2016/11/05/iOSDataBinding/)