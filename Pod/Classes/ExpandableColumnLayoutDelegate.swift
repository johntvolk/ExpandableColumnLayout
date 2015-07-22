//
//  ColumnLayoutDelegate.swift
//  Novu
//
//  Created by John Volk on 6/30/14.
//  Copyright (c) 2014 Novu. All rights reserved.
//

import UIKit

@objc public protocol ExpandableColumnLayoutDelegate: UICollectionViewDelegate {
    
    func numberOfColumnsInCollectionView(collectionView: UICollectionView,
        layout expandableColumnLayout: ExpandableColumnLayout,
        forSectionAtIndex section: Int) -> Int;
    
    func collectionView(collectionView: UICollectionView,
        layout expandableColumnLayout: ExpandableColumnLayout,
        sectionIsExpandedAtIndex section: Int) -> Bool;
    
    optional func baseHeightMultiplierInCollectionView(collectionView: UICollectionView,
        layout columnLayout: ExpandableColumnLayout) -> CGFloat;

    optional func collectionView(collectionView: UICollectionView,
        layout expandableColumnLayout: ExpandableColumnLayout,
        itemHasExactHeightAtIndexPath indexPath: NSIndexPath!) -> Bool;
    
    optional func collectionView(collectionView: UICollectionView,
        layout expandableColumnLayout: ExpandableColumnLayout,
        exactHeightForItemAtIndexPath indexPath: NSIndexPath!,
        withWidth width: CGFloat) -> CGFloat;
    
    optional func collectionView(collectionView: UICollectionView,
        layout expandableColumnLayout: ExpandableColumnLayout,
        unitHeightForItemAtIndexPath indexPath: NSIndexPath!) -> Int;
    
    optional func collectionView(collectionView: UICollectionView,
        layout expandableColumnLayout: ExpandableColumnLayout,
        sizeForHeaderInSection section: Int) -> CGSize;
    
    optional func collectionView(collectionView: UICollectionView,
        layout expandableColumnLayout: ExpandableColumnLayout,
        itemSpacingInSection section: Int) -> CGFloat;
    
    optional func collectionView(collectionView: UICollectionView,
        layout expandableColumnLayout: ExpandableColumnLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets;
}
