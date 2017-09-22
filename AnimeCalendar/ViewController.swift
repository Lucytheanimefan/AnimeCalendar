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
    
    var animeSchedule = [Int:[[String:Any]]]()
    
    var animeDailySchedule = [[String:Any]]()
    
    // The today's anime table
    @IBOutlet weak var tableView: NSTableView!
    
    // Today's normal events
    @IBOutlet weak var normieTableView: NSTableView!
    
    @IBOutlet var dateTextView: NSTextView!
    
    var animeEventController:AnimeEventController!
    
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
    
    override func viewDidAppear() {
        self.animeEventController = AnimeEventController(window: NSApplication.shared().windows.first!)
        //self.animeEventController.eventAuthFailAlert()
        self.animeEventController.updateAuthStatus()
        self.animeEventController.createCalendars()
        
    }
    
    func setUpAniList(){
        self.newAniList = NewAnimeList(clientID: "kowaretasekai-xquxb", clientSecret: "T5yjmG9hn3x5LvLK7lKTP")
        self.newAniList.authenticate { (accessToken) in
             self.newAniList.generateThisMonthAnime(month: 9, completion: { (calendarDict) in
                self.animeSchedule = calendarDict
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
             })
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
        // [[row, column]]
        print("Change item to highlight state")

        let first = indexPaths.first!
        let index = (first.section * 7) + (first.item)
        
         self.dateTextView.string = calendar.component(.month, from: Date()).description + "-" + (index+1).description + "-" + calendar.component(.year, from: Date()).description
        
        if let anime = self.animeSchedule[index]
        {
            self.animeDailySchedule = anime
                
            DispatchQueue.main.async
            {
                self.tableView.reloadData()
            }
        }
        
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
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
        return sections
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "CalendarViewItem", for: indexPath)
        if let collectionViewItem = item as? CalendarViewItem{
            let index = (indexPath.section*7) + indexPath.item
            if (index < self.days.count)
            {
                collectionViewItem.textField?.stringValue = String(describing:self.days[index]) + "  "
                if let animez = self.animeSchedule[index]{

                    for anime in animez{
                       if let title = anime["title_english"] as? String{
                            
                            if ( collectionViewItem.textField?.stringValue  != nil)
                            {
                                collectionViewItem.textField?.stringValue  = ( collectionViewItem.textField?.stringValue )! + title
                            }
                            else
                            {
                                collectionViewItem.textField?.stringValue = title
                            }
                            
                            // Set image indicating there's anime on this day
                            collectionViewItem.imageView?.image = #imageLiteral(resourceName: "AnimeDayIcon")
            
                            
                        }
                        
//                        if let imageURL = anime["image_url_banner"] as? String{
//                            if let url = URL(string: imageURL){
//                                collectionViewItem.imageView?.image = NSImage(byReferencing: url)
//                            }
//                        }
                    }
                }
//                else
//                {
//                    collectionViewItem.textField?.stringValue = String(describing:self.days[index])
//                }
            }
            
            return collectionViewItem
        }
        return item
    }
}


extension ViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        // Return number of anime airing for that day
        return (self.animeDailySchedule.count)
    }
}

extension ViewController: NSTableViewDelegate{
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cellView = tableView.make(withIdentifier: "animeViewID", owner: nil) as? NSTableCellView{
            if let title = self.animeDailySchedule[row]["title_english"] as? String
            {
                cellView.textField?.stringValue = title
            }
            
            return cellView
        }
        else
        {
            return nil
        }
        
        //let rowIndex = tableView.selectedRow
    }

}

