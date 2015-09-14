//
//  SectionExpander.swift
//  Pods
//
//  Created by John Volk on 9/12/15.
//  Copyright (c) 2015 John Volk. All rights reserved.
//

import UIKit

public class SectionExpander {
    
    private var expandedSections = Set<Int>();
    
    public var multipleExpansionEnabled = true;
    
    public func toggleExpansionForSectionAtIndex(section: Int, inCollectionView collectionView: UICollectionView, withAnimationDuration duration: NSTimeInterval) {
        if let dataSource = collectionView.dataSource {
            let itemCount = dataSource.collectionView(collectionView, numberOfItemsInSection: section);
            var itemsToInsert = [NSIndexPath]();
            var itemsToDelete = [NSIndexPath]();
            
            if self.expandedSections.contains(section) {
                self.expandedSections.remove(section);
                
                for i in 0 ..< itemCount {
                    itemsToDelete.append(NSIndexPath(forItem: i, inSection: section));
                }
            } else {
                if !self.multipleExpansionEnabled {
                    for expandedSection in self.expandedSections {
                        let itemCount = dataSource.collectionView(collectionView, numberOfItemsInSection: expandedSection);
                        
                        for i in 0 ..< itemCount {
                            itemsToDelete.append(NSIndexPath(forItem: i, inSection: expandedSection));
                        }
                    }
                    
                    self.expandedSections.removeAll(keepCapacity: true);
                }
                
                self.expandedSections.insert(section);
                
                let itemCount = dataSource.collectionView(collectionView, numberOfItemsInSection: section);
                
                for i in 0 ..< itemCount {
                    itemsToInsert.append(NSIndexPath(forItem: i, inSection: section));
                }
            }
            
            UIView.animateWithDuration(duration, animations: { () -> Void in
                collectionView.performBatchUpdates({ () -> Void in
                    collectionView.insertItemsAtIndexPaths(itemsToInsert);
                    collectionView.deleteItemsAtIndexPaths(itemsToDelete);
                }, completion: { [weak self] (finished: Bool) -> Void in
                    if let firstInsert = itemsToInsert.first {
                        collectionView.scrollToItemAtIndexPath(firstInsert,
                            atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true);
                    }
                });
            });
        }
    }
    
    public func expandSectionAtIndex(section: Int) {
        self.expandedSections.insert(section);
    }
    
    public func collapseSectionAtIndex(section: Int) {
        self.expandedSections.remove(section);
    }
    
    public func sectionIsExpandedAtIndex(section: Int) -> Bool {
        return self.expandedSections.contains(section);
    }
}