## BedtimeClock

[![Platform](https://img.shields.io/badge/platform-iOS%20|%20macOS%20|%20watchOS%20|%20tvOS-orange.svg)](https://github.com/LeonardoCardoso/SwiftLinkPreview#requirements-and-details)
[![CocoaPods](https://img.shields.io/badge/pod-v0.0.1-red.svg)](https://github.com/LeonardoCardoso/BedtimeClock#cocoapods)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/LeonardoCardoso/BedtimeClock#carthage)
[![Cookiecutter-Swift](https://img.shields.io/badge/cookiecutter--swift-framework-red.svg)](http://github.com/cookiecutter-swift/Framework)

> Just a bedtime clock for your app

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Requirements

- iOS 9.0+ / Mac OS X 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build BedtimeClock 0.0.1+.

To integrate BedtimeClock into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'BedtimeClock', '~> 0.0.1'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate BedtimeClock into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "BedtimeClock/BedtimeClock" ~> 0.0.1
```

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate BedtimeClock into your project manually.

#### Git Submodules

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```bash
$ git init
```

- Add BedtimeClock as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

```bash
$ git submodule add https://github.com/leocardz.com/BedtimeClock.git
$ git submodule update --init --recursive
```

- Open the new `BedtimeClock` folder, and drag the `BedtimeClock.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `BedtimeClock.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `BedtimeClock.xcodeproj` folders each with two different versions of the `BedtimeClock.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from.

- Select the `BedtimeClock.framework`.

- And that's it!

## Usage

## License

BedtimeClock is released under the MIT license. See [LICENSE](https://github.com/leocardz.com/BedtimeClock/blob/master/LICENSE) for details.
