# Tweak Settings
A dedicated settings app for tweak preferences

![preview](Resources/icon_large.png)

# Building

| Scheme   | Command                                                  | Architecture      |
|----------|----------------------------------------------------------|-------------------|
| rootful  | `make package`                                           | `iphoneos-arm`    |
| rootless | `make package THEOS_PACKAGE_SCHEME=rootless`             | `iphoneos-arm64`  |
| roothide | `make package THEOS_PACKAGE_SCHEME=roothide`             | `iphoneos-arm64e` |

RootHide builds need the [roothide/theos](https://github.com/roothide/theos) fork (provides `roothide.h` / `libroothide`).
Build with Xcode 26 or newer to get the Liquid Glass interface. The app uses the UIScene life cycle, which UIKit requires from iOS 27.

# Author

Dana Buehre (CreatureSurvive)
[cs@creaturecoding.com](mailto:cs@creaturecoding.com)

© Dana Buehre (CreatureSurvive) 2021
