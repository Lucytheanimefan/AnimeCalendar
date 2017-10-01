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
    
    var newAniList:NewAnimeList! = NewAnimeList.sharedInstance
    
    var animeSchedule = [Int:[[String:Any]]]()
    
    var animeDailySchedule = [[String:Any]]()
    
    let userDefaults = UserDefaults.standard
    
    var previousSelectedCellView:NSView!
    
    var dateOffset:Int! = 0
    
    // The today's anime table
    @IBOutlet weak var tableView: NSTableView!
    
    // Today's normal events
    @IBOutlet weak var normieTableView: NSTableView!
    
    @IBOutlet weak var calendarTableView: NSTableView!
    @IBOutlet weak var calendarHeaderView: NSTableHeaderView!
    
    @IBOutlet var dateTextView: NSTextView!
    
    var animeEventController:AnimeEventController!

    var imageCount:Int = 0
    
    var currentDate:Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateTextView.alignment = .center
        self.dateTextView.font = NSFont(name: "Helvetica Neue", size: 20)
        self.calendarTableView.selectionHighlightStyle = .none
        self.calendarTableView.allowsColumnSelection = true
        (self.calendarTableView as! CustomTableView).cellSelectionDelegate = self
        self.calendarHeaderView.layer?.backgroundColor = NSColor.clear.cgColor
        calculateDateOffset()
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
        let today = self.currentDate
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        var components = DateComponents()
        components.year = year
        components.month = month
        let newDate = calendar.date(from: components)
        let range = calendar.range(of: .day, in: .month, for: newDate!)!
        let numDays = range.count
        return Double(numDays)
    }
    
    func calculateDateOffset(){
        // Get first day of month
        let components = calendar.dateComponents([.year, .month, .weekday], from: self.currentDate.startOfMonth())
        self.dateOffset = components.weekday! - 1
    }
    
    @IBAction func previousMonth(_ sender: NSButton) {
        if let prevMonth = Calendar.current.date(byAdding: .month, value: -1, to: self.currentDate)
        {
            self.currentDate = prevMonth
            calculateDateOffset()
            self.calendarTableView.reloadData()
            setUpAniList()
        }
    }
    
    @IBAction func nextMonth(_ sender: NSButton) {
        if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: self.currentDate)
        {
            self.currentDate = nextMonth
            calculateDateOffset()
            self.calendarTableView.reloadData()
            setUpAniList()
        }
    }
    
}


extension DayViewController:CalendarCellSelectionDelegate{
    func cellViewWasSelected(tableView: NSTableView, row: Int, col: Int) {
        if (self.previousSelectedCellView != nil)
        {
            self.previousSelectedCellView.layer?.backgroundColor = NSColor.clear.cgColor
        }
        let cellView = tableView.view(atColumn: col, row: row, makeIfNecessary: false)
        self.previousSelectedCellView = cellView
        cellView?.layer?.backgroundColor = NSColor.gray.cgColor
        
        // Display the data in anime day tableview
        let index = (row * 7) + col - self.dateOffset
        let monthName = DateFormatter().monthSymbols[calendar.component(.month, from: self.currentDate)-1]

        self.dateTextView.string = monthName + " " + (index+1).description + ", " + calendar.component(.year, from: Date()).description
        self.animeDailySchedule = [[String:Any]]()
        if let anime = self.animeSchedule[index]
        {
            self.animeDailySchedule = anime
            
            DispatchQueue.main.async
                {
                    self.tableView.reloadData()
            }
        }
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
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 20
    }
    

    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view:NSView? = nil
        if (tableView.identifier == "calendarTableViewID")
        {
            if ((row == 0 && tableView.tableColumns.index(of: tableColumn!)! >= self.dateOffset) || row > 0 ){
                if let cellView = tableView.make(withIdentifier: "animeDayViewID", owner: nil) as? NSTableCellView{
                    let index = (row*7) + tableView.tableColumns.index(of: tableColumn!)! - self.dateOffset
                    if (index < Int((daysInMonth()).rounded(.up))){
                        cellView.textField?.stringValue = String(describing:index + 1)// + " "
                    }
                    //cellView.textField?.textColor = NSColor.black
                    view = cellView
                }
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

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}



