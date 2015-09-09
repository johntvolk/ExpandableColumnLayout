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

class ViewController: ExpandableColumnViewController {

    let EXAMPLE_CELL_REUSE_ID = "exampleCell";
    let EXAMPLE_HEADER_REUSE_ID = "exampleHeader";
    
    @IBOutlet var expansionToggle: UISegmentedControl!;

    let sections = [(8, 16), (5, 10), (3, 6), (2, 4)];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.collectionView.alwaysBounceVertical = true;
        self.multipleExpansionEnabled = false;
        self.collectionView.registerNib(UINib(nibName: "ExampleCell", bundle: nil),
            forCellWithReuseIdentifier: EXAMPLE_CELL_REUSE_ID);
        self.collectionView.registerNib(UINib(nibName: "ExampleHeader", bundle: nil),
            forSupplementaryViewOfKind: ExpandableColumnLayoutHeaderKind,
            withReuseIdentifier: EXAMPLE_HEADER_REUSE_ID);
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.count;
    }
    
    override func numberOfColumnsInCollectionView(collectionView: UICollectionView, layout expandableColumnLayout: ExpandableColumnLayout, forSectionAtIndex section: Int) -> Int {
        return self.sections[section].0;
    }
    
    override func numberOfItemsInExpandedSection(section: Int) -> Int {
        return self.sections[section].1;
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let exampleCell = collectionView.dequeueReusableCellWithReuseIdentifier(EXAMPLE_CELL_REUSE_ID, forIndexPath: indexPath) as! ExampleCell;
        
        exampleCell.titleLabel.text = String(indexPath.item);
        exampleCell.backgroundColor = generateRandomColor();
        
        return exampleCell;
    }
    
    override func viewForSupplementaryHeaderElementAtIndexPath(indexPath: NSIndexPath) -> UICollectionReusableView {
        let exampleHeader = self.collectionView.dequeueReusableSupplementaryViewOfKind(ExpandableColumnLayoutHeaderKind,
            withReuseIdentifier: EXAMPLE_HEADER_REUSE_ID,
            forIndexPath: indexPath) as! ExampleHeader;
        
        exampleHeader.titleLabel.text = "Section " + String(indexPath.section);
        exampleHeader.backgroundColor = generateRandomColor();
        exampleHeader.addGestureRecognizer(HeaderTapRecognizer(section: indexPath.section, target: self, action: "headerTapped:"));
        
        return exampleHeader;
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
    
    func headerTapped(recognizer: HeaderTapRecognizer) {
        self.toggleExpansionForSectionAtIndex(recognizer.section, withDuration: 0.5);
    }
    
    @IBAction func expansionToggled(sender: AnyObject) {
        self.multipleExpansionEnabled = self.expansionToggle.selectedSegmentIndex == 1;
    }
    
    private func generateRandomColor() -> UIColor {
        let hue = (CGFloat(arc4random() % 256) / 256.0);
        let saturation = (CGFloat(arc4random() % 128) / 256.0) + 0.5;
        let brightness = (CGFloat(arc4random() % 128) / 256.0) + 0.5;
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

