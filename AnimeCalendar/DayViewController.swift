//
//  DayViewController.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 9/23/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa
import AppKit
import os.log

class DayViewController: NSViewController {
    
    //@IBOutlet weak var collectionView: NSCollectionView!
    
    let calendar = Calendar.current
    
    var days = [Int]()
    
    var newAniList:NewAnimeList! = NewAnimeList.sharedInstance
    
    var animeSchedule = [Int:[[String:Any]]]()
    
    var animeDailySchedule = [[String:Any]]()
    
    let userDefaults = UserDefaults.standard
    
    var selectedColIndex:Int = 0
    
    // The today's anime table
    @IBOutlet weak var tableView: NSTableView!
    
    // Today's normal events
    @IBOutlet weak var normieTableView: NSTableView!
    
    @IBOutlet weak var calendarTableView: NSTableView!
    
    
    @IBOutlet var dateTextView: NSTextView!
    
    var animeEventController:AnimeEventController!
    
    
    
    var imageCount:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateTextView.alignment = .center
        self.dateTextView.font = NSFont(name: "Helvetica Neue", size: 20)
        self.calendarTableView.selectionHighlightStyle = .none
        self.calendarTableView.allowsColumnSelection = true
        (self.calendarTableView as! CustomTableView).cellSelectionDelegate = self
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
        // While making the request, use cached value if exists
        if let cached = self.userDefaults.object(forKey: "animeSchedule") as? Data
        {
            if let cachedSchedule = NSKeyedUnarchiver.unarchiveObject(with: cached) as? [Int:[[String:Any]]]
            {
                self.animeSchedule = cachedSchedule
                DispatchQueue.main.async
                    {
                        //self.collectionView.reloadData()
                        self.calendarTableView.reloadData()
                }
            }
        }
        
        self.newAniList.monthAnimeList(completion: { (calendarDict) in
            
        }) {
            self.animeSchedule = self.newAniList.calendarDict
            self.userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: self.animeSchedule), forKey: "animeSchedule")
            DispatchQueue.main.async
            {
                //self.collectionView.reloadData()
                self.calendarTableView.reloadData()
            }
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

//
//extension DayViewController:NSCollectionViewDelegate
//{
//    func collectionView(_ collectionView: NSCollectionView, didChangeItemsAt indexPaths: Set<IndexPath>, to highlightState: NSCollectionViewItemHighlightState) {
//
//        let first = indexPaths.first!
//        let index = (first.section * 7) + (first.item)
//
//        let monthName = DateFormatter().monthSymbols[calendar.component(.month, from: Date())-1]
//        //print(monthName)
//        self.dateTextView.string = monthName + " " + (index+1).description + ", " + calendar.component(.year, from: Date()).description
//        self.animeDailySchedule = [[String:Any]]()
//        if let anime = self.animeSchedule[index]
//        {
//            self.animeDailySchedule = anime
//
//            DispatchQueue.main.async
//                {
//                    self.tableView.reloadData()
//            }
//        }
//
//    }
//
//    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
//
//    }
//}

//extension DayViewController:NSCollectionViewDataSource
//{
//    @available(OSX 10.11, *)
//    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
//        if (section < (Int((daysInMonth()/7).rounded(.up))-1))
//        {
//            return 7
//        }
//        else
//        {
//            return (Int(daysInMonth().truncatingRemainder(dividingBy: 7)) + 1)
//        }
//    }
//
//    func numberOfSections(in collectionView: NSCollectionView) -> Int {
//        let sections = Int((daysInMonth()/7).rounded(.up))
//        return sections
//    }
//
//    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
//        let item = collectionView.makeItem(withIdentifier: "CalendarViewItem", for: indexPath)
//        if let collectionViewItem = item as? CalendarViewItem {
//
//            let index = (indexPath.section*7) + indexPath.item
//            collectionViewItem.textField?.stringValue = String(describing:index + 1) + "  "
//            if let animez = self.animeSchedule[index]{
//
//                for anime in animez{
//                    if let title = anime["title_english"] as? String
//                    {
//
//                        if ( collectionViewItem.textField?.stringValue  != nil)
//                        {
//                            collectionViewItem.textField?.stringValue  = ( collectionViewItem.textField?.stringValue )! + title
//
//                            if (collectionViewItem.imageView?.image == nil && (collectionViewItem.textField?.stringValue != nil))
//                            {
//                                imageCount+=1
//                                os_log("%@: Image count: %@, for index: %@", self.className, imageCount.description, index.description)
//                                collectionViewItem.imageView?.image = #imageLiteral(resourceName: "AnimeDayIcon")
//                            }
//                        }
//                        else
//                        {
//                            collectionViewItem.textField?.stringValue = title
//                            // Set image indicating there's anime on this day
//
//                        }
//
//                    }
//
////                    if let imageURL = anime["image_url_banner"] as? String{
////                        if let url = URL(string: imageURL){
////                            collectionViewItem.imageView?.image = NSImage(byReferencing: url)
////                        }
////                    }
//                }
//            }
//
//            return collectionViewItem
//        }
//        return item
//    }
//}

extension DayViewController:CalendarCellSelectionDelegate{
    func cellViewWasSelected(tableView: NSTableView, row: Int, col: Int) {
        let cellView = tableView.view(atColumn: col, row: row, makeIfNecessary: false)
        cellView?.layer?.backgroundColor = NSColor.red.cgColor
    }
}

extension DayViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        if (tableView.identifier == "calendarTableViewID")
        {
            return Int((daysInMonth()/7).rounded(.up))
        }
        // Return number of anime airing for that day
        return (self.animeDailySchedule.count)
    }
}

extension DayViewController: NSTableViewDelegate{
//    func tableViewSelectionDidChange(_ notification: Notification) {
//        let rowIndex = self.calendarTableView.selectedRow
//        let colIndex = self.selectedColIndex
//    }
    
    func tableView(_ tableView: NSTableView, shouldSelect tableColumn: NSTableColumn?) -> Bool {
        self.selectedColIndex = tableView.tableColumns.index(of: tableColumn!)!
        return true
    }
    
//    func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
//        if (row == tableView.selectedRow && tableColumn == tableView.tableColumns[tableView.selectedColumn])
//        {
//            (cell as! NSTableViewCell)
//        }
//    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view:NSView!
        if (tableView.identifier == "calendarTableViewID")
        {
             if let cellView = tableView.make(withIdentifier: "animeDayViewID", owner: nil) as? NSTableCellView{
                let index = (row*7) + tableView.tableColumns.index(of: tableColumn!)!
                cellView.textField?.stringValue = String(describing:index) + " "
                if let animez = self.animeSchedule[index]{
                    
                    for anime in animez{
                        if let title = anime["title_english"] as? String
                        {
                            if ( cellView.textField?.stringValue  != nil)
                            {
                                cellView.textField?.stringValue  = ( cellView.textField?.stringValue )! + title
                                
//                                if (collectionViewItem.imageView?.image == nil && (collectionViewItem.textField?.stringValue != nil))
//                                {
                                    imageCount+=1
                                    os_log("%@: Image count: %@, for index: %@", self.className, imageCount.description, index.description)
                                    //cellView.imageView?.image = #imageLiteral(resourceName: "AnimeDayIcon")
                                //}
                            }
                            else
                            {
                                cellView.textField?.stringValue = title
                            }
                        }
                    }
                }
                view = cellView
            }
            
            
        }
        else
        {
            if let cellView = tableView.make(withIdentifier: "animeViewID", owner: nil) as? NSTableCellView{
                if let title = self.animeDailySchedule[row]["title_english"] as? String
                {
                    cellView.textField?.stringValue = title
                }
                
                view = cellView
            }
            else
            {
                return nil
            }
        }
        
        return view
    }
}



