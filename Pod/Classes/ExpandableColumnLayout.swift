//
//  ExpandableColumnLayout.swift
//  Pods
//
//  Created by John Volk on 6/30/14.
//  Copyright (c) 2015 John Volk. All rights reserved.
//

import UIKit

public let ExpandableColumnLayoutHeaderKind = "columnLayoutHeader";
public let ExpandableColumnLayoutSectionBackgroundKind = "columnLayoutSectionBackground";

public class ExpandableColumnLayout: UICollectionViewLayout {
    
    private var itemLayoutAttrs = [NSIndexPath: UICollectionViewLayoutAttributes]();
    private var previousItemLayoutAttrs = [NSIndexPath: UICollectionViewLayoutAttributes]();
    private var initialItemOverrides = [NSIndexPath: UICollectionViewLayoutAttributes]();
    private var finalItemOverrides = [NSIndexPath: UICollectionViewLayoutAttributes]();
    private var headerLayoutAttrs = [NSIndexPath: UICollectionViewLayoutAttributes]();
    private var previousHeaderLayoutAttrs = [NSIndexPath: UICollectionViewLayoutAttributes]();
    private var backgroundLayoutAttrs = [NSIndexPath: UICollectionViewLayoutAttributes]();
    private var previousBackgroundLayoutAttrs = [NSIndexPath: UICollectionViewLayoutAttributes]();
    private var initialSupplementaryOverrides = [NSIndexPath: UICollectionViewLayoutAttributes]();
    private var finalSupplementaryOverrides = [NSIndexPath: UICollectionViewLayoutAttributes]();
    private var expandedSections = [Int: Bool]();
    private var sectionHeights = [Int: CGFloat]();
    private var previousSectionHeights = [Int: CGFloat]();
    private var totalHeight: CGFloat = 0.0;

    override public func prepareLayout() {
        super.prepareLayout();
        
        if let collectionView = self.collectionView, delegate = collectionView.delegate as? ExpandableColumnLayoutDelegate {
            self.previousItemLayoutAttrs = self.itemLayoutAttrs;
            self.previousHeaderLayoutAttrs = self.headerLayoutAttrs;
            self.previousBackgroundLayoutAttrs = self.backgroundLayoutAttrs;
            self.previousSectionHeights = self.sectionHeights;
            self.itemLayoutAttrs = [NSIndexPath: UICollectionViewLayoutAttributes]();
            self.headerLayoutAttrs = [NSIndexPath: UICollectionViewLayoutAttributes]();
            self.backgroundLayoutAttrs = [NSIndexPath: UICollectionViewLayoutAttributes]();
            self.sectionHeights = [Int: CGFloat]();
            
            let frame = collectionView.frame;
            let optionalBaseHeight = delegate.baseHeightMultiplierInCollectionView?(collectionView, layout: self);
            let baseHeightMultiplier = optionalBaseHeight == nil ? 1.0 : optionalBaseHeight!;
            var columnHeights = Dictionary<Int, CGFloat>();
            var zIndex = collectionView.numberOfSections() * 3;
            
            self.totalHeight = 0;
            
            for i in 0 ..< collectionView.numberOfSections() {
                let sectionYOrigin = self.totalHeight;
                var sectionHeight: CGFloat = 0.0;
                
                if let headerSize = delegate.collectionView?(collectionView, layout: self, sizeForHeaderInSection: i) { // Add header.
                    if headerSize != CGSizeZero {
                        let headerIndexPath = NSIndexPath(forItem: 0, inSection: i);
                        let attrs = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ExpandableColumnLayoutHeaderKind,
                            withIndexPath: headerIndexPath);
                        
                        attrs.zIndex = zIndex;
                        attrs.frame = CGRect(x: 0.0, y: self.totalHeight, width: headerSize.width, height: headerSize.height);
                        
                        self.headerLayoutAttrs[headerIndexPath] = attrs;
                        self.totalHeight += headerSize.height;
                    }
                }
                
                zIndex--;
                
                let optionalInsets = delegate.collectionView?(collectionView, layout: self, insetForSectionAtIndex: i);
                let sectionInsets = optionalInsets != nil ? optionalInsets! : UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0);
                let numItems = collectionView.numberOfItemsInSection(i);
                let numColumns = delegate.numberOfColumnsInCollectionView(collectionView, layout: self, forSectionAtIndex: i);
                let optionalSpacing = delegate.collectionView?(collectionView, layout: self, itemSpacingInSection: i);
                let interitemSpacing = optionalSpacing == nil ? 0.0 : optionalSpacing!;
                let columnWidth = ((frame.size.width - (CGFloat(numColumns - 1) * interitemSpacing) - (sectionInsets.left + sectionInsets.right)) / CGFloat(numColumns));
                var xPosition: CGFloat = sectionInsets.left;
                
                if numItems > 0 {
                    self.totalHeight += sectionInsets.top;

                    for j in 0 ..< numItems { // Add items.
                        let indexPath = NSIndexPath(forItem: j, inSection: i);
                        let column = j % numColumns;
                        var currentColumnHeight: CGFloat = 0.0;
                        var height: CGFloat = 0.0;
                        
                        if let exactHeight = delegate.collectionView?(collectionView, layout: self, itemHasExactHeightAtIndexPath: indexPath) where exactHeight {
                            height = delegate.collectionView!(collectionView, layout: self, exactHeightForItemAtIndexPath: indexPath, withWidth: columnWidth);
                        } else if let unitHeight = delegate.collectionView?(collectionView, layout: self, unitHeightForItemAtIndexPath: indexPath) {
                            let baseHeight = Int(floor(columnWidth * baseHeightMultiplier));
                            
                            height = CGFloat(baseHeight * unitHeight) + (interitemSpacing * CGFloat(unitHeight - 1));
                        } else {
                            fatalError("ExpandleColumnLayoutDelegate must specify either a unitHeight or exactHeight for every item.");
                        }
                        
                        let addSpacing = j < numItems - numColumns;
                        
                        if let columnHeight = columnHeights[column] {
                            currentColumnHeight = columnHeight;
                            columnHeights[column] = height + columnHeight + (addSpacing ? interitemSpacing : 0.0);
                        } else {
                            columnHeights[column] = currentColumnHeight + height + (addSpacing ? interitemSpacing : 0.0)
                        }
                        
                        xPosition = column == 0 ? sectionInsets.left : xPosition;
                        xPosition = xPosition + (column != 0 ? interitemSpacing : 0.0);
                        
                        let attrs = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath);
                        
                        attrs.zIndex = zIndex;
                        attrs.frame = CGRect(x: xPosition, y: currentColumnHeight + self.totalHeight, width: columnWidth, height: height);
                        self.itemLayoutAttrs[indexPath] = attrs;
                        
                        xPosition += columnWidth;
                    }
                    
                    var maxSectionHeight: CGFloat = 0.0;
                    
                    for (column, height) in columnHeights {
                        maxSectionHeight = maxSectionHeight < height ? height : maxSectionHeight;
                    }
                    
                    columnHeights.removeAll(keepCapacity: true);
                    self.totalHeight += maxSectionHeight;
                    self.totalHeight += sectionInsets.bottom;
                    sectionHeight = maxSectionHeight + sectionInsets.top + sectionInsets.bottom;
                }
                
                zIndex--;

                let backgroundIndexPath = NSIndexPath(forItem: 0, inSection: i);
                let attrs = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: ExpandableColumnLayoutSectionBackgroundKind,
                    withIndexPath: backgroundIndexPath);
                
                attrs.zIndex = zIndex--;
                attrs.frame = CGRect(x: 0.0, y: sectionYOrigin, width: frame.size.width, height: self.totalHeight - sectionYOrigin);
                
                self.backgroundLayoutAttrs[backgroundIndexPath] = attrs;
                self.sectionHeights[i] = sectionHeight;
            }
        }
    }
    
    override public func collectionViewContentSize() -> CGSize {
        return CGSize(width: self.collectionView!.frame.size.width, height: self.totalHeight);
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var result = [AnyObject]();

        for (indexPath, layoutAttrs) in self.itemLayoutAttrs {
            if CGRectIntersectsRect(rect, layoutAttrs.frame) {
                result.append(layoutAttrs);
            }
        }
        
        for (indexPath, layoutAttrs) in self.headerLayoutAttrs {
            if CGRectIntersectsRect(rect, layoutAttrs.frame) {
                result.append(layoutAttrs);
            }
        }
        
        for (indexPath, layoutAttrs) in self.backgroundLayoutAttrs {
            if CGRectIntersectsRect(rect, layoutAttrs.frame) {
                result.append(layoutAttrs);
            }
        }
        
        return result;
    }
    
    override public func prepareForCollectionViewUpdates(updateItems: [AnyObject]!) {
        super.prepareForCollectionViewUpdates(updateItems);
        
        if let collectionView = self.collectionView, delegate = collectionView.delegate as? ExpandableColumnLayoutDelegate {
        
            // Step through all updates.
            // Place each update in a map based off NSIndexPath (before / after update will vary).
            // Find earliest update in collection.
            // Start at earliest item and go through each item by checking for an item with an increasing NSIndexPath
            // Keep track of section and item level deltas.
            // Use deltas to build overrides.
            
            var sectionUpdates = [NSIndexPath: UICollectionViewUpdateItem]();
            var itemUpdates = [NSIndexPath: UICollectionViewUpdateItem]();
            var earliestSectionUpdate: Int?;
            var earliestItemUpdate: NSIndexPath?;
            
            for updateItem in updateItems as! [UICollectionViewUpdateItem] { // Collect information about updates.
                if updateItem.updateAction == UICollectionUpdateAction.Insert || updateItem.updateAction == UICollectionUpdateAction.Delete {
                    if let indexPath = updateItem.updateAction == UICollectionUpdateAction.Insert ? updateItem.indexPathAfterUpdate : updateItem.indexPathBeforeUpdate {
                        if indexPath.item == NSNotFound {
                            sectionUpdates[indexPath] = updateItem;
                            earliestSectionUpdate = self.findEarliestSectionUpdate(earliestSectionUpdate, candidateUpdate: indexPath.section);
                        } else {
                            itemUpdates[indexPath] = updateItem;
                            earliestItemUpdate = self.findEarliestItemUpdate(earliestItemUpdate, candidateUpdate: indexPath);
                        }
                    }
                }
            }
            
            if earliestSectionUpdate != nil || earliestItemUpdate != nil {
                var currentIndexPath: NSIndexPath = self.findStartingIndexPath(earliestSectionUpdate, earliestItemUpdate: earliestItemUpdate);
                var previousExpandedSections = self.expandedSections;
                var foundLastItem = false;
                var sectionDelta = 0;
                var itemDelta = 0;
                
                while(!foundLastItem) {
                    var foundSectionUpdate = false;
                    var foundItemUpdate = false;
                    
                    if currentIndexPath.item == 0 {
                        if let sectionUpdate = sectionUpdates[NSIndexPath(forItem: NSNotFound, inSection: currentIndexPath.section)] {
                            foundSectionUpdate = true;
                            
                            let isInsert = sectionUpdate.updateAction == UICollectionUpdateAction.Insert;
                            
                            if isInsert {
                                sectionDelta++;
                                self.initialSupplementaryOverrides[currentIndexPath] = self.buildFadeOverride(self.headerLayoutAttrs[currentIndexPath]); // Fade in header.
                                currentIndexPath = NSIndexPath(forItem: currentIndexPath.item + 1, inSection: currentIndexPath.section);
                            } else {
                                sectionDelta--;
                                self.finalSupplementaryOverrides[currentIndexPath] = self.buildFadeOverride(self.previousHeaderLayoutAttrs[currentIndexPath]); // Fade out header.
                                
                                if self.previousItemLayoutAttrs[currentIndexPath] != nil {
                                    while let deletedItemAttrs = self.previousItemLayoutAttrs[currentIndexPath] { // Fade out items.
                                        self.finalItemOverrides[currentIndexPath] = self.buildFadeOverride(deletedItemAttrs);
                                        currentIndexPath = NSIndexPath(forItem: currentIndexPath.item + 1, inSection: currentIndexPath.section);
                                    }
                                } else {
                                    currentIndexPath = NSIndexPath(forItem: currentIndexPath.item + 1, inSection: currentIndexPath.section);
                                }
                            }
                            
                            self.expandedSections = self.buildUpdatedExpandedSectionsForSectionDelta(currentIndexPath.section, insert: isInsert);
                        }
                    }
                    
                    if !foundSectionUpdate {
                        if let itemUpdate = itemUpdates[currentIndexPath] {
                            foundItemUpdate = true;
                            
                            let isInsert = itemUpdate.updateAction == UICollectionUpdateAction.Insert;
                            let deltaSectionIndex = currentIndexPath.section + (isInsert ? -sectionDelta : sectionDelta);
                            let deltaSectionIndexPath = NSIndexPath(forItem: 0, inSection: deltaSectionIndex);
                            let isExpanded = delegate.collectionView(collectionView, layout: self, sectionIsExpandedAtIndex: isInsert ? currentIndexPath.section : deltaSectionIndex);
                            var wasExpanded = false;
                            
                            if let expanded = previousExpandedSections[isInsert ? deltaSectionIndex : currentIndexPath.section] {
                                wasExpanded = expanded;
                            }
                            
                            self.expandedSections[isInsert ? currentIndexPath.section : deltaSectionIndex] = isExpanded;
                            
                            if itemUpdate.updateAction == UICollectionUpdateAction.Insert {
                                itemDelta++;
                                
                                if isExpanded == wasExpanded { // Insert single item.
                                    self.initialItemOverrides[currentIndexPath] = self.buildFadeOverride(self.itemLayoutAttrs[currentIndexPath]);
                                } else { // Expand whole section.
                                    self.initialItemOverrides[currentIndexPath] = self.buildSlideOverride(self.itemLayoutAttrs[currentIndexPath],
                                        startingHeaderAttrs: self.headerLayoutAttrs[deltaSectionIndexPath],
                                        endingHeaderAttrs: self.previousHeaderLayoutAttrs[deltaSectionIndexPath],
                                        sectionHeight: self.sectionHeights[currentIndexPath.section]);
                                }
                            } else {
                                itemDelta--;
                                
                                if isExpanded == wasExpanded { // Delete single item.
                                    self.finalItemOverrides[currentIndexPath] = self.buildFadeOverride(self.previousItemLayoutAttrs[currentIndexPath]);
                                } else { // Collapse whole section.
                                    self.finalItemOverrides[currentIndexPath] = self.buildSlideOverride(self.previousItemLayoutAttrs[currentIndexPath],
                                        startingHeaderAttrs: self.previousHeaderLayoutAttrs[deltaSectionIndexPath],
                                        endingHeaderAttrs: self.headerLayoutAttrs[deltaSectionIndexPath],
                                        sectionHeight: self.previousSectionHeights[currentIndexPath.section]);
                                }
                            }
                        }
                        
                        if !foundItemUpdate {
                            if sectionDelta != 0 {
                                let deltaIndexPath = NSIndexPath(forItem: currentIndexPath.item, inSection: currentIndexPath.section + sectionDelta);
                                
                                if let headerAttrs = self.headerLayoutAttrs[deltaIndexPath] { // Move headers.
                                    if let finalAttrsOverride = headerAttrs.copy() as? UICollectionViewLayoutAttributes {
                                        finalAttrsOverride.indexPath = currentIndexPath;
                                        self.finalSupplementaryOverrides[currentIndexPath] = finalAttrsOverride;
                                    }
                                    
                                    if let initialAttrsOverride = headerAttrs.copy() as? UICollectionViewLayoutAttributes {
                                        self.initialSupplementaryOverrides[deltaIndexPath] = initialAttrsOverride;
                                    }
                                }
                            }
                            
                            if sectionDelta != 0 || itemDelta != 0 {
                                let deltaIndexPath = NSIndexPath(forItem: currentIndexPath.item + itemDelta, inSection: currentIndexPath.section + sectionDelta);
                                
                                if let itemAttrs = self.itemLayoutAttrs[deltaIndexPath] { // Move items.
                                    if let finalAttrsOverride = itemAttrs.copy() as? UICollectionViewLayoutAttributes {
                                        finalAttrsOverride.indexPath = currentIndexPath;
                                        self.finalItemOverrides[currentIndexPath] = finalAttrsOverride;
                                    }
                                    
                                    if let initialAttrsOverride = itemAttrs.copy() as? UICollectionViewLayoutAttributes {
                                        self.initialItemOverrides[deltaIndexPath] = initialAttrsOverride;
                                    }
                                }
                            }
                        }
                        
                        currentIndexPath = NSIndexPath(forItem: currentIndexPath.item + 1, inSection: currentIndexPath.section);
                    }
                    
                    if self.itemLayoutAttrs[currentIndexPath] == nil && self.previousItemLayoutAttrs[currentIndexPath] == nil {
                        itemDelta = 0;
                        currentIndexPath = NSIndexPath(forItem: 0, inSection: currentIndexPath.section + 1);
                        foundLastItem = self.itemLayoutAttrs[currentIndexPath] == nil && self.previousItemLayoutAttrs[currentIndexPath] == nil &&
                            self.headerLayoutAttrs[currentIndexPath] == nil && self.previousHeaderLayoutAttrs[currentIndexPath] == nil;
                    }
                }
            }
        }
    }
    
    private func findEarliestSectionUpdate(earliestSectionUpdate: Int?, candidateUpdate: Int) -> Int {
        if let earliestUpdate = earliestSectionUpdate {
            return earliestUpdate > candidateUpdate ? candidateUpdate : earliestUpdate;
        } else {
            return candidateUpdate;
        }
    }
    
    private func findEarliestItemUpdate(earliestItemUpdate: NSIndexPath?, candidateUpdate: NSIndexPath) -> NSIndexPath {
        if let earliestUpdate = earliestItemUpdate {
            return earliestUpdate.compare(candidateUpdate) == NSComparisonResult.OrderedDescending ? candidateUpdate : earliestUpdate;
        } else {
            return candidateUpdate;
        }
    }
    
    private func findStartingIndexPath(earliestSectionUpdate: Int?, earliestItemUpdate: NSIndexPath?) -> NSIndexPath {
        if earliestSectionUpdate != nil && earliestItemUpdate != nil {
            return earliestSectionUpdate! <= earliestItemUpdate!.section ? NSIndexPath(forItem: 0, inSection: earliestSectionUpdate!) : earliestItemUpdate!;
        } else if earliestSectionUpdate != nil {
            return NSIndexPath(forItem: 0, inSection: earliestSectionUpdate!);
        } else {
            return earliestItemUpdate!;
        }
    }
    
    private func buildUpdatedExpandedSectionsForSectionDelta(sectionDeltaIndex: Int, insert: Bool) -> [Int: Bool] {
        var updatedExpandedSections: [Int: Bool] = [:];
        
        for (sectionIndex, expanded) in self.expandedSections {
            if (sectionDeltaIndex <= sectionIndex && insert) || (sectionDeltaIndex < sectionIndex && !insert) {
                updatedExpandedSections[sectionIndex + (insert ? 1 : -1)] = expanded;
            } else if sectionDeltaIndex > sectionIndex {
                updatedExpandedSections[sectionIndex] = expanded;
            }
        }
        
        return updatedExpandedSections;
    }
    
    private func buildSlideOverride(itemAttrs: UICollectionViewLayoutAttributes?, startingHeaderAttrs: UICollectionViewLayoutAttributes?,
        endingHeaderAttrs: UICollectionViewLayoutAttributes?, sectionHeight: CGFloat?) -> UICollectionViewLayoutAttributes? {
            if let itemAttrs = itemAttrs {
                let result = itemAttrs.copy() as! UICollectionViewLayoutAttributes;
                let resultFrame = result.frame;
                var yPosition = resultFrame.origin.y;
                
                if let sectionHeight = sectionHeight, startingHeaderAttrs = startingHeaderAttrs, endingHeaderAttrs = endingHeaderAttrs {
                    let offset = (startingHeaderAttrs.frame.origin.y + sectionHeight) - resultFrame.origin.y;

                    yPosition = endingHeaderAttrs.frame.origin.y - offset;
                } else {
                    result.alpha = 0.0;
                }

                result.frame = CGRect(x: resultFrame.origin.x, y: yPosition, width: resultFrame.size.width, height: resultFrame.size.height);
                
                return result;
            }
        
            return nil;
    }
    
    private func buildFadeOverride(attrs: UICollectionViewLayoutAttributes?) -> UICollectionViewLayoutAttributes? {
        if let attrs = attrs {
            if let attrsOverride = attrs.copy() as? UICollectionViewLayoutAttributes {
                attrsOverride.alpha = 0.0;
                return attrsOverride;
            }
        }
        
        return nil;
    }
    
    override public func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates();
        
        self.initialItemOverrides.removeAll(keepCapacity: true);
        self.finalItemOverrides.removeAll(keepCapacity:true);
        self.initialSupplementaryOverrides.removeAll(keepCapacity: true);
        self.finalSupplementaryOverrides.removeAll(keepCapacity: true);
    }
    
    override public func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if let attrsOverride = self.initialItemOverrides[itemIndexPath] {
            return attrsOverride;
        } else if let result = self.previousItemLayoutAttrs[itemIndexPath]?.copy() as? UICollectionViewLayoutAttributes {
            return result;
        }
        
        return nil;
    }
    
    override public func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if let attrsOverride = self.finalItemOverrides[itemIndexPath] {
            return attrsOverride;
        } else if let result = self.itemLayoutAttrs[itemIndexPath]?.copy() as? UICollectionViewLayoutAttributes {
            return result;
        }
        
        return nil;
    }
    
    override public func initialLayoutAttributesForAppearingSupplementaryElementOfKind(elementKind: String, atIndexPath elementIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == ExpandableColumnLayoutHeaderKind {
            if let attrsOverride = self.initialSupplementaryOverrides[elementIndexPath] {
                return attrsOverride;
            } else if let result = self.previousHeaderLayoutAttrs[elementIndexPath]?.copy() as? UICollectionViewLayoutAttributes {
                return result;
            }
        } else if let result = self.previousBackgroundLayoutAttrs[elementIndexPath]?.copy() as? UICollectionViewLayoutAttributes {
            return result;
        }
        
        return nil;
    }
    
    override public func finalLayoutAttributesForDisappearingSupplementaryElementOfKind(elementKind: String, atIndexPath elementIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == ExpandableColumnLayoutHeaderKind {
            if let attrsOverride = self.finalSupplementaryOverrides[elementIndexPath] {
                return attrsOverride;
            } else if let result = self.headerLayoutAttrs[elementIndexPath]?.copy() as? UICollectionViewLayoutAttributes {
                return result;
            }
        } else if let result = self.backgroundLayoutAttrs[elementIndexPath]?.copy() as? UICollectionViewLayoutAttributes {
            return result;
        }
        
        return nil;
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return self.itemLayoutAttrs[indexPath];
    }
    
    override public func layoutAttributesForSupplementaryViewOfKind(elementKind: String,
        atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
            return elementKind == ExpandableColumnLayoutHeaderKind ? self.headerLayoutAttrs[indexPath] : self.backgroundLayoutAttrs[indexPath];
    }
}
