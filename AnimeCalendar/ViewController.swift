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
    
    var days = [Int]()
    
    var newAniList:NewAnimeList!
    
    var animeSchedule=[[String:Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.isSelectable = true
        setUpAniList()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func setUpAniList(){
        newAniList = NewAnimeList(clientID: "kowaretasekai-xquxb", clientSecret: "T5yjmG9hn3x5LvLK7lKTP")
        newAniList.authenticate { (accessToken) in
            self.newAniList.animeToDate(completion: { (animeDict) in
                //print(animeDict)
                self.animeSchedule = animeDict
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            })
            
             self.newAniList.generateThisMonthAnime()
        }
        
       
    }
    
    func daysInMonth() -> Double{
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        var components = DateComponents()
        components.year = year
        components.month = month
        let newDate = calendar.date(from: components)
        let range = calendar.range(of: .day, in: .month, for: newDate!)!
        let numDays = range.count
        self.days = Array(1...numDays)
        return Double(numDays)
    }
}


extension ViewController:NSCollectionViewDelegate
{
    func collectionView(_ collectionView: NSCollectionView, didChangeItemsAt indexPaths: Set<IndexPath>, to highlightState: NSCollectionViewItemHighlightState) {
        //print("Change item to highlight state")
    }
}

extension ViewController:NSCollectionViewDataSource
{
    @available(OSX 10.11, *)
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        let sections = Int((daysInMonth()/7).rounded(.up))
        print (sections)
        return sections
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "CalendarViewItem", for: indexPath)
        if let collectionViewItem = item as? CalendarViewItem{
            let index = (indexPath.section*7) + indexPath.item
            if (index < self.days.count)
            {
//                let animeSched = self.animeSchedule as NSArray
//                let predicate = NSPredicate(format: "updated_at==%i", 1505766602)
//                let filteredEntries = animeSched.filtered(using: predicate)
//                print(filteredEntries)
                if (self.animeSchedule.indices.contains(index)){
                    let anime = self.animeSchedule[index]
                    if let date = anime["updated_at"] as? NSNumber{
                        let time = NSDate(timeIntervalSince1970: TimeInterval(date))
                        collectionViewItem.textField?.stringValue = time.description
                    }
                    if let title = anime["title_english"] as? String{
                        //(collectionViewItem.sourceItemView as? NSTextView)?.string = title
                        collectionViewItem.textField?.stringValue = title
                        
                    }
                    
                    if let imageURL = anime["image_url_banner"] as? String{
                        if let url = URL(string: imageURL){
                            collectionViewItem.imageView?.image = NSImage(byReferencing: url)
                        }
                    }
                    //collectionViewItem.textField?.stringValue = self.animeSchedule[index]//String(describing:self.days[index])
                }
                else
                {
                    collectionViewItem.textField?.stringValue = ""
                }
                return collectionViewItem
            }
        }
        return item
    }
}


