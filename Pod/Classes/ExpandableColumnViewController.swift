//
//  ExpandableColumnViewController.swift
//  Pods
//
//  Created by John Volk on 9/8/15.
//
//

import Foundation

public class ExpandableColumnViewController: UIViewController, ExpandableColumnLayoutDelegate, UICollectionViewDataSource {
    
    private let SECTION_BACKGROUND_REUSE_ID = "expandableSectionBackground";
    
    private var expandedSections = Set<Int>();
    
    public var multipleExpansionEnabled = true;
    public var delegate: ExpandableColumnLayoutDelegate?;
    
    @IBOutlet public var collectionView: UICollectionView!;
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.collectionViewLayout = ExpandableColumnLayout();
        self.collectionView.registerClass(UICollectionReusableView.self,
            forSupplementaryViewOfKind: ExpandableColumnLayoutSectionBackgroundKind,
            withReuseIdentifier: SECTION_BACKGROUND_REUSE_ID)
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sectionIsExpandedAtIndex(section) ? self.numberOfItemsInExpandedSection(section) : 0;
    }
    
    public func numberOfItemsInExpandedSection(section: Int) -> Int {
        fatalError("Subclasses of ExpandableColumnViewController must override this method.");
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        fatalError("Subclasses of ExpandableColumnViewController must override this method.");
    }
    
    public func numberOfColumnsInCollectionView(collectionView: UICollectionView, layout expandableColumnLayout: ExpandableColumnLayout, forSectionAtIndex section: Int) -> Int {
        fatalError("Subclasses of ExpandableColumnViewController must override this method.");
    }
    
    public func collectionView(collectionView: UICollectionView, layout expandableColumnLayout: ExpandableColumnLayout, sectionIsExpandedAtIndex section: Int) -> Bool {
        return self.sectionIsExpandedAtIndex(section);
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == ExpandableColumnLayoutSectionBackgroundKind {
            let exampleBackground = collectionView.dequeueReusableSupplementaryViewOfKind(ExpandableColumnLayoutSectionBackgroundKind,
                withReuseIdentifier: SECTION_BACKGROUND_REUSE_ID,
                forIndexPath: indexPath) as! UICollectionReusableView;
            
            exampleBackground.backgroundColor = self.collectionView.backgroundColor;
            
            return exampleBackground;
        } else {
            return self.viewForSupplementaryHeaderElementAtIndexPath(indexPath);
        }
    }
    
    public func viewForSupplementaryHeaderElementAtIndexPath(indexPath: NSIndexPath) -> UICollectionReusableView {
        fatalError("Subclasses of ExpandableColumnViewController must override this method.");
    }
    
    public func sectionIsExpandedAtIndex(section: Int) -> Bool {
        return self.expandedSections.contains(section);
    }
    
    public func toggleExpansionForSectionAtIndex(section: Int, withDuration duration: NSTimeInterval) {
        if let dataSource = self.collectionView.dataSource {
            let itemCount = dataSource.collectionView(self.collectionView, numberOfItemsInSection: section);
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
                        let itemCount = dataSource.collectionView(self.collectionView, numberOfItemsInSection: expandedSection);
                        
                        for i in 0 ..< itemCount {
                            itemsToDelete.append(NSIndexPath(forItem: i, inSection: expandedSection));
                        }
                    }
                    
                    self.expandedSections.removeAll(keepCapacity: true);
                }
                
                self.expandedSections.insert(section);
                
                let itemCount = dataSource.collectionView(self.collectionView, numberOfItemsInSection: section);
                
                for i in 0 ..< itemCount {
                    itemsToInsert.append(NSIndexPath(forItem: i, inSection: section));
                }
            }
            
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.collectionView.performBatchUpdates({ [weak self] () -> Void in
                    if let capturedSelf = self {
                        capturedSelf.collectionView.insertItemsAtIndexPaths(itemsToInsert);
                        capturedSelf.collectionView.deleteItemsAtIndexPaths(itemsToDelete);
                    }
                    }, completion: { [weak self] (finished: Bool) -> Void in
                        if let firstInsert = itemsToInsert.first {
                            if let capturedSelf = self {
                                capturedSelf.collectionView.scrollToItemAtIndexPath(firstInsert,
                                    atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true);
                            }
                        }
                    });
            });
        }
    }
}