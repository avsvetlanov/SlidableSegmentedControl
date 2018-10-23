## SlidableSegmentedControl
[![Platform](http://img.shields.io/badge/platform-iOS-blue.svg?style=flat)](https://cocoapods.org/?q=segmentio) [![License](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/Yalantis/Segmentio/blob/master/LICENSE) ![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg)

iOS Slidable segmented control with highlighting text under slidable selecting view written in Swift.

![Preview](https://github.com/avsvetlanov/SlidableSegmentedControl/blob/master/preview.gif)

## Requirements

- iOS 9.x+
- Swift 4.2

## Usage

#### Init
You can initialize a `SlidableSegmentedControl` instance from code:

```swift
var segmentedControl: SlidableSegmentedControl!

let segmentedControlRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40)
segmentedControl = SlidableSegmentedControl(frame: segmentedControlRect)
view.addSubview(segmentedControl)
```

or

add a `UIView` instance in your .storyboard or .xib, set `SlidableSegmentedControl` class and connect `IBOutlet`:

```swift
@IBOutlet weak var segmentedControl: SlidableSegmentedControl!
```

#### Usage
Insert segment:
```swift
segmentedControl.insertSegment(withTitle: "Some text", at: 0)
```

Remove segment:
```swift
segmentedControl.removeSegment(at: 0)
```

Select segment:
```swift
segmentedControl.selectSegment(at: 0, animated: true)
```

#### Handling callback
You can handle selected item with closure:
```swift
segmentedControl.onSelection = { sender in
	print("Selected index: ", sender.selectedSegmentIndex)
}
```

Or you can use delegate:
```swift
// MARK: SlidableSegmentedControlDelegate
func didSelectSegment(sender: SlidableSegmentedControl) {
	print("Selected index: ", sender.selectedSegmentIndex)
}
```

#### Customization
`SlidableSegmentedControl` can be customized by changing constants in struct:

```swift
    public struct Constants {
        public static var height: CGFloat = 29
        public static var cornerRadius: CGFloat = 14.5
        public static var font: UIFont = UIFont.systemFont(ofSize: 14)
        public static var normalTextColor: UIColor = .gray
        public static var normalBackgroundColor: UIColor = .lightGray
        public static var selectedTextColor: UIColor = .orange
        public static var selectedBackgroundColor: UIColor = .white
        public static var selectedBorderColor: UIColor = .orange
        public static var selectedBorderWidth: CGFloat = 1
        public static var insertAnimationDuration: TimeInterval = 0.24
        public static var panGestureTriggerVelocity: CGFloat = 500
    }
```

## License

The MIT License (MIT)

Copyright © 2018 Yalantis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
