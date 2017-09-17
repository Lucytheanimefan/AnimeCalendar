//
//  ViewController.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 9/16/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa
import AppKit

class ViewController: NSViewController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    let calendar = Calendar.current
    
    var days:[Int]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func daysInMonth() -> Int{
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        var components = DateComponents()
        components.year = year
        components.month = month
        let newDate = calendar.date(from: components)
        let range = calendar.range(of: .day, in: .month, for: newDate!)!
        let numDays = range.count
        self.days = Array(0...numDays)
        return numDays
    }
}


extension ViewController:NSCollectionViewDelegate
{
    
}

extension ViewController:NSCollectionViewDataSource
{
    @available(OSX 10.11, *)
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int((daysInMonth()/4))
    }

    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "Date", for: indexPath)
        item.textField?.stringValue = "foo1"
        if let collectionViewItem = item as? CollectionViewItem{
            collectionViewItem.textField?.stringValue = "foo2"//String(describing:self.days[indexPath.count])
            return collectionViewItem
        }
        return item
    }
    
}


