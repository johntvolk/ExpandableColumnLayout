# ExpandableColumnLayout

[![CI Status](http://img.shields.io/travis/John Volk/ExpandableColumnLayout.svg?style=flat)](https://travis-ci.org/John Volk/ExpandableColumnLayout)
[![Version](https://img.shields.io/cocoapods/v/ExpandableColumnLayout.svg?style=flat)](http://cocoapods.org/pods/ExpandableColumnLayout)
[![License](https://img.shields.io/cocoapods/l/ExpandableColumnLayout.svg?style=flat)](http://cocoapods.org/pods/ExpandableColumnLayout)
[![Platform](https://img.shields.io/cocoapods/p/ExpandableColumnLayout.svg?style=flat)](http://cocoapods.org/pods/ExpandableColumnLayout)

A custom UICollectionViewLayout that provides a flexible column-based layout with optional expandable drawer functionality.

* Arbitrary column count per section
* Specifiy unit-height or exact height per item
* Expand or contract sections via attractive drawer-like animation

![demo](demo.gif)

## Installation

ExpandableColumnLayout is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ExpandableColumnLayout"
```

## Usage

ExpanableColumnLayout relies on an instance of ExpandableColumnLayoutDelegate to provide the information it needs to build the layout. ExpandableColumnLayoutDelegate is a sub-type of UICollectionViewDelegate and so inherits any of the required behavior of that protocol. In addition, it adds some required behavior of it's own.

The following two methods _must_ be implemented

```swift
func numberOfColumnsInCollectionView(collectionView: UICollectionView,
  layout expandableColumnLayout: ExpandableColumnLayout,
  forSectionAtIndex section: Int) -> Int;
    
func collectionView(collectionView: UICollectionView,
  layout expandableColumnLayout: ExpandableColumnLayout,
  sectionIsExpandedAtIndex section: Int) -> Bool;
```

There are two ways to integrate ExpandableColumnLayout into your project.

##### Easy Way

The quickest way to get going is to subclass the provided ExpandableColumnViewController. This is the method used in the example project. When you subclass ExpandableColumnViewController there are two methods that you need to override in addition to the standard UICollectionViewDelegate / UICollectionViewDataSource methods.

```swift
public func numberOfItemsInExpandedSection(section: Int) -> Int {
  return 5;
}

public func collectionView(collectionView: UICollectionView,
  cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    fatalError("Subclasses of ExpandableColumnViewController must override this method.");
}
  
public func numberOfColumnsInCollectionView(collectionView: UICollectionView,
  layout expandableColumnLayout: ExpandableColumnLayout, forSectionAtIndex section: Int) -> Int {
    fatalError("Subclasses of ExpandableColumnViewController must override this method.");
}
```

## Author

John Volk, john.t.volk@gmail.com

## License

ExpandableColumnLayout is available under the MIT license. See the LICENSE file for more info.
