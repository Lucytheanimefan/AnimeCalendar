//
//  DayViewController.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 9/23/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa
import AppKit

class DayViewController: NSViewController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    let calendar = Calendar.current
    
    var days = [Int]()
    
    var newAniList:NewAnimeList! = NewAnimeList.sharedInstance
    
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
        self.dateTextView.alignment = .center
        self.dateTextView.font = NSFont(name: "Helvetica Neue", size: 20)
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
        
        self.newAniList.monthAnimeList { (calendarDict) in
            self.animeSchedule = calendarDict
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
            
//            = NewAnimeList(clientID: "kowaretasekai-xquxb", clientSecret: "T5yjmG9hn3x5LvLK7lKTP")
//        self.newAniList.authenticate { (accessToken) in
//            self.newAniList.generateThisMonthAnime(month: self.calendar.component(.month, from: Date()), completion: { (calendarDict) in
//                self.animeSchedule = calendarDict
//                //print(self.animeSchedule)
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
//            })
//        }
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


extension DayViewController:NSCollectionViewDelegate
{
    func collectionView(_ collectionView: NSCollectionView, didChangeItemsAt indexPaths: Set<IndexPath>, to highlightState: NSCollectionViewItemHighlightState) {
        // [[row, column]]
        //print("Change item to highlight state")
        
        let first = indexPaths.first!
        let index = (first.section * 7) + (first.item)
        
        let monthName = DateFormatter().monthSymbols[calendar.component(.month, from: Date())-1]
        //print(monthName)
        self.dateTextView.string = monthName + " " + (index+1).description + ", " + calendar.component(.year, from: Date()).description
        
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

extension DayViewController:NSCollectionViewDataSource
{
    @available(OSX 10.11, *)
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section < (Int((daysInMonth()/7).rounded(.up))-1))
        {
            return 7
        }
        else
        {
            return (Int(daysInMonth().truncatingRemainder(dividingBy: 7)) + 1)
        }
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        let sections = Int((daysInMonth()/7).rounded(.up))
        return sections
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "CalendarViewItem", for: indexPath)
        if let collectionViewItem = item as? CalendarViewItem {
            
            let index = (indexPath.section*7) + indexPath.item
            collectionViewItem.textField?.stringValue = String(describing:index + 1) + "  "
            if let animez = self.animeSchedule[index]{
                
                for anime in animez{
                    if let title = anime["title_english"] as? String{
                        //print(anime)
                        
                        if ( collectionViewItem.textField?.stringValue  != nil)
                        {
                            collectionViewItem.textField?.stringValue  = ( collectionViewItem.textField?.stringValue )! + title
                        }
                        else
                        {
                            collectionViewItem.textField?.stringValue = title
                        }
                        
                        // Set image indicating there's anime on this day
                        //collectionViewItem.imageView?.image = #imageLiteral(resourceName: "AnimeDayIcon")
                    }
                    
                    if let imageURL = anime["image_url_banner"] as? String{
                        if let url = URL(string: imageURL){
                            collectionViewItem.imageView?.image = NSImage(byReferencing: url)
                        }
                    }
                }
                //}
            }
            
            return collectionViewItem
        }
        return item
    }
}


extension DayViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        // Return number of anime airing for that day
        return (self.animeDailySchedule.count)
    }
}

extension DayViewController: NSTableViewDelegate{
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



