//
//  ExpandableColumnViewController.swift
//  Pods
//
//  Created by John Volk on 9/8/15.
//  Copyright (c) 2015 John Volk. All rights reserved.
//

import UIKit

public class ExpandableColumnViewController: UIViewController, ExpandableColumnLayoutDelegate, UICollectionViewDataSource {
    
    private let SECTION_BACKGROUND_REUSE_ID = "expandableSectionBackground";
    
    private let sectionExpander = SectionExpander();
    
    @IBOutlet public var collectionView: UICollectionView!;
    
    public var expandAllSections = false;
    
    public var multipleExpansionEnabled: Bool {
        get {
            return self.sectionExpander.multipleExpansionEnabled;
        }
        
        set(newValue) {
            self.sectionExpander.multipleExpansionEnabled = newValue;
        }
    }
    
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
        return self.expandAllSections || self.sectionExpander.sectionIsExpandedAtIndex(section);
    }
    
    public func toggleExpansionForSectionAtIndex(section: Int, withAnimationDuration duration: NSTimeInterval) {
        self.sectionExpander.toggleExpansionForSectionAtIndex(section, inCollectionView: self.collectionView, withAnimationDuration: duration);
    }
    
    public func expandSectionAtIndex(section: Int) {
        self.sectionExpander.expandSectionAtIndex(section);
    }
    
    public func collapseSectionAtIndex(section: Int) {
        self.sectionExpander.collapseSectionAtIndex(section);
    }
}