# KetchupUI

[中文版](/README.zh-cn.md)

A foundational UI library for video wall and TV-like interactive applications. Features an underlying canvas that supports semantic awareness of video wall seams, enabling software applications to adapt to large-scale video wall usage scenarios right from the design phase.

![portrait](pic/demo_1.0.0_dev.1.gif)

This software uses the [AGPL v3 Open Source License](/LICENSE). You must open-source commercial code developed based on this license within your ecosystem. Alternatively, contact the author at jackyanjiaqi@gmail.com or WeChat: DigitalSpriteJack to purchase a commercial closed-source license.

# Core Features

-   **(Framework)** Design responsive interfaces using `ScreenContext` and `GridContext`, minimizing dependency on specific resolutions.
-   **(Design)** Design elements are aware of physical video wall seams, employing various methods to automatically avoid these edges for an improved experience.
-   **(Interaction)** Enable multi-user online interaction for large screens or video walls using QR code scanning with mobile phones.
-   **(Framework)** A self-developed `Navigation-Page-Focus` system supporting the creation of virtual screen contexts within pages for nested page structures.
-   **(Business)** Built for casual games; pairs with `flutter_map` and `flutter_flame` libraries to develop multiplayer split-screen games based on large maps.
-   **(Device)** TV-first design. Create page elements for both large screens and mobile devices simultaneously. Multi-screen mode deploys content for macOS, Windows, and Linux large screens, while single-screen mode deploys control clients for Android and iOS.

## Roadmap

-   1.1.0 Support for Code Repository Management | Options and Downloads, and DEMO demonstration 📅
-   1.0.x Refine follow-up features for the launcher 1.0 demo 📅
-   1.0.0 Full support for launcher 1.0 demo features released [Version 1.0 Release Notes](/CHANGELOG.md) ✅
-   0.x.x Version update support for game-kit and assets-kit (migrating components or type declarations) ✅
-   0.2.x (Non-Runtime) Interaction mode switching TV<->Keyboard/Mouse<->Touch ✅
-   0.1.x Page Navigator supports animated transitions ✅
-   0.1.0 Support for **Layer Drawing Context** + Page Navigator + Code Repository ✅
-   0.0.2 Support for **Grid Context** + Context Container ✅
-   0.0.1 Support for **Multi-Screen Context** and interaction preset options ✅

# Launcher (Commercial) Project

A commercial closed-source project built upon KetchupUI, providing games and applications with a unified launcher interface and settings. This is the main project for external demonstrations. Downloads correspond to options in the code repository. The open-source version only provides the most basic demonstration and code repository option capabilities. To download the commercial version or a demo, please contact WeChat: DigitalSpriteJack.

# Dependent Libraries

The framework does not use third-party state management tools, adhering to a minimal dependency design. It utilizes the Flutter platform's native `State` mechanism, distinguishing only between Game Launcher State, Page State, and UI State. Future versions will refactor the `ContextAccessor` functionality into `Controller`s.

## Derived Libraries

-   [pixel-assets-kit](https://github.com/jackyanjiaqi/pixel-assets-kit) Pixel-style text and images suitable for large-screen games, rendered without using font files.
-   [gridbased-game-kit](https://github.com/jackyanjiaqi/simple-gridbased-game-kit) A foundational toolkit for grid-based large-screen tile games, containing game loops, game logic, interaction solutions, and grid-based page extensions.
-   `narrative-puzzle-co-op-game-kit` A toolkit for narrative puzzle games, providing cooperative puzzle-solving gameplay. This internal toolkit is a paid option.
-   `multiplayer-splitscreen-cardboard-game-kit` A toolkit for multiplayer split-screen card and board games, providing shared-screen tabletop gameplay. This internal toolkit is a paid option.