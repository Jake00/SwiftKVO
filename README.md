# SwiftKVO

[![CI Status](http://img.shields.io/travis/Jake000/SwiftKVO.svg?style=flat)](https://travis-ci.org/Jake00/SwiftKVO)
[![Version](https://img.shields.io/cocoapods/v/SwiftKVO.svg?style=flat)](http://cocoapods.org/pods/SwiftKVO)
[![License](https://img.shields.io/cocoapods/l/SwiftKVO.svg?style=flat)](http://cocoapods.org/pods/SwiftKVO)
[![Platform](https://img.shields.io/cocoapods/p/SwiftKVO.svg?style=flat)](http://cocoapods.org/pods/SwiftKVO)

## Usage

```Swift
let observer = PropertyObserver(observed: <#NSObject#>, events: <#[String : (AnyObject?, AnyObject?) -> Void]#>, isInitiallyObserving: <#Bool#>)
```

#### Example

```Swift
func scrollViewContentOffsetDidChange(oldValue: AnyObject?, newValue: AnyObject?) {
    if let contentOffset = newValue?.CGPointValue() {
        // Do something with the new content offset...
    }
}

let observer = PropertyObserver(observed: self.scrollView, events: [
    "contentOffset": scrollViewContentOffsetDidChange
    ])
```

## Requirements

If installing using Cocoapods, then a deployment target of iOS 8 or higher is required due to dynamic framework linking.

If you prefer to install manually then the minimum deployment target is loosened to iOS 7 or higher due to Swift not being available for iOS 6 and below.

## Installation

#### Cocoapods

SwiftKVO is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'SwiftKVO'
```

#### Manually

Just copy and paste the single class file, PropertyObserver.swift into your project!

## Author

Jake00, Jakeyrox@gmail.com

## License

SwiftKVO is available under the MIT license. See the LICENSE file for more info.
