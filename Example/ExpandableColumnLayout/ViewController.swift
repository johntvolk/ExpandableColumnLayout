//
//  ViewController.swift
//  ExpandableColumnLayout
//
//  Created by John Volk on 07/20/2015.
//  Copyright (c) 2015 John Volk. All rights reserved.
//

import UIKit
import ExpandableColumnLayout

class HeaderTapRecognizer: UITapGestureRecognizer {
    
    let section: Int;
    
    init(section: Int, target: AnyObject, action: Selector) {
        self.section = section;
        super.init(target: target, action: action);
    }
}

class ViewController: UIViewController, UICollectionViewDataSource, ExpandableColumnLayoutDelegate {

    let EXAMPLE_CELL_REUSE_ID = "exampleCell";
    let EXAMPLE_HEADER_REUSE_ID = "exampleHeader";
    let EXAMPLE_SECTION_BACKGROUND_REUSE_ID = "exampleSectionBackground";
    
    @IBOutlet var collectionView: UICollectionView!;
    @IBOutlet var selectionToggle: UISegmentedControl!;

    let sections = [(8, 16), (5, 10), (3, 6), (2, 4)];
    var expandedSections = Set<Int>();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.collectionViewLayout = ExpandableColumnLayout();
        self.collectionView.alwaysBounceVertical = true;
        
        self.collectionView.registerNib(UINib(nibName: "ExampleCell", bundle: nil),
            forCellWithReuseIdentifier: EXAMPLE_CELL_REUSE_ID);
        self.collectionView.registerNib(UINib(nibName: "ExampleHeader", bundle: nil),
            forSupplementaryViewOfKind: ExpandableColumnLayoutHeaderKind,
            withReuseIdentifier: EXAMPLE_HEADER_REUSE_ID);
        self.collectionView.registerClass(UICollectionReusableView.self,
            forSupplementaryViewOfKind: ExpandableColumnLayoutSectionBackgroundKind,
            withReuseIdentifier: EXAMPLE_SECTION_BACKGROUND_REUSE_ID)
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.count;
    }
    
    func numberOfColumnsInCollectionView(collectionView: UICollectionView, layout expandableColumnLayout: ExpandableColumnLayout, forSectionAtIndex section: Int) -> Int {
        return self.sections[section].0;
    }
    
    func collectionView(collectionView: UICollectionView, layout expandableColumnLayout: ExpandableColumnLayout, sectionIsExpandedAtIndex section: Int) -> Bool {
        return expandedSections.contains(section);
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.expandedSections.contains(section) ? self.sections[section].1 : 0;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let exampleCell = collectionView.dequeueReusableCellWithReuseIdentifier(EXAMPLE_CELL_REUSE_ID, forIndexPath: indexPath) as! ExampleCell;
        
        exampleCell.titleLabel.text = String(indexPath.item);
        exampleCell.backgroundColor = generateRandomColor();
        
        return exampleCell;
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == ExpandableColumnLayoutHeaderKind {
            let exampleHeader = collectionView.dequeueReusableSupplementaryViewOfKind(ExpandableColumnLayoutHeaderKind,
                withReuseIdentifier: EXAMPLE_HEADER_REUSE_ID,
                forIndexPath: indexPath) as! ExampleHeader;
            
            exampleHeader.titleLabel.text = "Section " + String(indexPath.section);
            exampleHeader.backgroundColor = generateRandomColor();
            exampleHeader.addGestureRecognizer(HeaderTapRecognizer(section: indexPath.section, target: self, action: "headerTapped:"));
            
            return exampleHeader;
        } else {
            let exampleBackground = collectionView.dequeueReusableSupplementaryViewOfKind(ExpandableColumnLayoutSectionBackgroundKind,
                withReuseIdentifier: EXAMPLE_SECTION_BACKGROUND_REUSE_ID,
                forIndexPath: indexPath) as! UICollectionReusableView;
            
            exampleBackground.backgroundColor = UIColor.lightGrayColor();
            
            return exampleBackground;
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout expandableColumnLayout: ExpandableColumnLayout, unitHeightForItemAtIndexPath indexPath: NSIndexPath!) -> Int {
        let columnCount = self.sections[indexPath.section].0;
        
        if columnCount % 2 == 0 {
            return 1;
        } else {
            return indexPath.item % 2 == 0 ? 1 : 2;
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout expandableColumnLayout: ExpandableColumnLayout, itemSpacingInSection section: Int) -> CGFloat {
        return 2.0;
    }
    
    func collectionView(collectionView: UICollectionView, layout expandableColumnLayout: ExpandableColumnLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0);
    }
    
    func collectionView(collectionView: UICollectionView, layout expandableColumnLayout: ExpandableColumnLayout, sizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: CGRectGetWidth(collectionView.bounds), height: 44.0);
    }
    
    /*func headerTapped(recognizer: HeaderTapRecognizer) {
        let section = recognizer.section;
        let itemCount = self.sections[section].1;
        var itemsToInsert = [NSIndexPath]();
        var itemsToDelete = [NSIndexPath]();
        
        if self.expandedSections.contains(section) {
            self.expandedSections.remove(section);
            
            for i in 0 ..< itemCount {
                itemsToDelete.append(NSIndexPath(forItem: i, inSection: section));
            }
        } else {
            self.expandedSections.insert(section);
            
            for i in 0 ..< itemCount {
                itemsToInsert.append(NSIndexPath(forItem: i, inSection: section));
            }
        }
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
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
    }*/
    
    func headerTapped(recognizer: HeaderTapRecognizer) {
        let section = recognizer.section;
        let itemCount = self.sections[section].1;
        var itemsToInsert = [NSIndexPath]();
        var itemsToDelete = [NSIndexPath]();
        
        
        
        if self.expandedSections.contains(section) {
            self.expandedSections.remove(section);
            
            for i in 0 ..< itemCount {
                itemsToDelete.append(NSIndexPath(forItem: i, inSection: section));
            }
        } else {
            if self.selectionToggle.selectedSegmentIndex == 0 {
                for expandedSection in self.expandedSections {
                    let itemCount = self.sections[expandedSection].1;
                    
                    for i in 0 ..< itemCount {
                        itemsToDelete.append(NSIndexPath(forItem: i, inSection: expandedSection));
                    }
                }
                
                self.expandedSections.removeAll(keepCapacity: true);
            }
            
            self.expandedSections.insert(section);
            
            for i in 0 ..< itemCount {
                itemsToInsert.append(NSIndexPath(forItem: i, inSection: section));
            }
        }
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
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
    
    private func generateRandomColor() -> UIColor {
        let hue = (CGFloat(arc4random() % 256) / 256.0);
        let saturation = (CGFloat(arc4random() % 128) / 256.0) + 0.5;
        let brightness = (CGFloat(arc4random() % 128) / 256.0) + 0.5;
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

