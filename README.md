# KetchupUI

拼接屏和类TV交互应用的UI基础类库，一款支持拼接屏语义感知的底层画布，让软件应用从设计阶段就适配大屏拼接屏使用场景。

![portrait](pic/demo_1.0.0_dev.1.gif)

软件使用 [AGPL v3开源协议](/LICENSE), 在您的生态代码中开源基于此协议开发的商业代码。或者联系作者 jackyanjiaqi@gmail.com 或者 vx：DigitalSpriteJack 购买商业闭源许可。

# 基本功能

- (框架) 通过屏幕语境`ScreenContext`和网格线语境`GridContext`设计响应式界面，最大化降低对分辨率的依赖
- (设计) 设计元素识别屏幕物理拼缝，多种手段自动绕开物理边缝提升体验
- (交互) 使用手机扫码方式大屏或拼接屏提供多人在线交互
- (框架) 自主研发的 `导航-页面-焦点` 体系，支持页面内创建虚拟屏幕语境进行页面嵌套
- (业务) 为休闲游戏而生，搭配 `flutter_map` 和 `flutter_flame` 库开发基于大地图的多人分屏游戏
- (设备) TV优先，一次性设计为大屏和移动设备的页面元素，多屏模式为 macos、windows、linux 进行大屏内容部署，单屏模式为 android、ios 进行移动控制端部署


## 路线图

- 1.1.0 支持 代码库管理｜选项和下载 以及 DEMO演示 📅
- 1.0.x 完善 launcher 1.0 演示后续功能 📅
- 1.0.0 能够完整支持 launcher 1.0 演示功能发布 [1.0版本说明文档](/CHANGELOG.zh-cn.md)  ✅
- 0.x.x 对 game-kit 和 assets-kit 的版本更新支持(下沉组件或类型声明) ✅
- 0.2.x (非运行时)交互模式切换 TV<->键鼠<->触控 ✅
- 0.1.x 页面导航器支持动画转场 ✅
- 0.1.0 支持 **层绘图语境** +页面导航器+代码资源库 ✅
- 0.0.2 支持 **网格线语境** +语境容器 ✅
- 0.0.1 支持 **多屏幕语境** 和交互预设选项 ✅

# Launcher 启动器(商业)项目

基于 KetchupUI 包装的商业闭源项目，为游戏和应用提供外观和统一设置功能，是对外演示的主体项目，根据代码库的选项进行相应下载，开源版本仅提供最基本的演示和代码库选项能力，下载商业版本或演示请联系 vx: DigitalSpriteJack。

# 依赖类库

框架未使用第三方状态管理工具，采用最小依赖设计，采用flutter平台 `State` 机制，只区分游戏 Launcher State、Page State 和 UI State，后续版本会将 `ContextAccessor` 功能 `Controller` 化。

## 派生类库
- [pixel-assets-kit](https://github.com/jackyanjiaqi/pixel-assets-kit) 适用于大屏游戏的像素风格的文字和图像，非字体方式绘制
- [gridbased-game-kit](https://github.com/jackyanjiaqi/simple-gridbased-game-kit) 适用于大屏方块类游戏的底层工具包，内含游戏循环、游戏逻辑、交互方案 和 基于网格线的页面扩展等
- `narrative-puzzle-co-op-game-kit` 剧情解谜游戏工具包，提供剧情解谜合作玩法，内部工具包付费可选
- `multiplayer-splitscreen-cardboard-game-kit` 多玩家分屏卡牌桌游工具包，提供棋牌桌游多人同屏玩法，内部工具包付费可选