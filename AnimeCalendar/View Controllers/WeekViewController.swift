//
//  WeekViewController.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 9/23/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa
import os.log

class WeekViewController: NSViewController {
    
    @IBOutlet var mainView: NSView!
    
    var newAniList:NewAnimeList! = NewAnimeList.sharedInstance
    
    var animeSchedule:[Int:[[String:Any]]]!
    
    @IBOutlet weak var tableView: CustomTableView!
    var previousSelectedCellView:NSView!
    
    lazy var weekDay = {
        return Calendar.current.component(.weekday, from: Date())
    }()
    
    var currentDate:Date! = Date()
    var clickedDate:Date! = Date()
    
    var weekDayOffset:Int = 0
    
    let contextualMenu = CalendarContextualMenu.shared
    
    var selectedRow:Int! = -1
    var selectedCol:Int! = -1
    
    var hashtag:String!
    
    @IBOutlet weak var currentMonthYear: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainView.wantsLayer = true
        self.mainView.layer?.backgroundColor = NSColor.clear.cgColor
        self.tableView.selectionHighlightStyle = .none
        self.tableView.cellSelectionDelegate = self
        self.setUpMonthlyAnime()
        self.setDateTitle()
        
        // Display pop up menu
        if (self.contextualMenu.menu != nil)
        {
            tableView.menu = self.contextualMenu.menu
        }
        
    }
    
    func weekDayDict() -> [Int:Int]
    {
        var dict = [Int:Int]()
        let dayValue = Calendar.current.component(.day, from: Date())
        dict[weekDay] = dayValue
        for i in 1...7{
            let diff = i - weekDay
            dict[i] = dayValue + diff
        }
        return dict
    }
    
    func setUpMonthlyAnime()
    {
        self.newAniList.monthAnimeList(completion: { (calendarDict) in
            self.animeSchedule = calendarDict
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }) {
            print("Done")
        }
    }
    
    func setDateTitle(){
        let monthName = DateFormatter().monthSymbols[Calendar.current.component(.month, from: self.currentDate)-1]
        let yearName = Calendar.current.component(.year, from: self.currentDate)
        self.currentMonthYear.stringValue = monthName + " " + String(describing:yearName)
    }
    
    
    
    @IBAction func nextWeek(_ sender: NSButton) {
        if let prevWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: self.currentDate)
        {
            self.currentDate = prevWeek
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func prevWeek(_ sender: NSButton) {
        if let nextWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: self.currentDate)
        {
            self.currentDate = nextWeek
            self.tableView.reloadData()
        }
    }
    
    @IBAction func doubleClickTable(_ sender: CustomTableView) {
        if let popUpView = self.contextualMenu.menu.item(at: 0)?.view as? CalendarPopUpMenuView {
            popUpView.imageViewDelegate = self
            // Clean up icons
            for view in popUpView.iconStackView.views{
                popUpView.iconStackView.removeView(view)
            }
            
            let dayIndex = Int(self.tableView.tableColumns[self.selectedCol].headerCell.stringValue)
            if let anime = self.animeSchedule[dayIndex!]
            {
                if (self.selectedRow < anime.count)
                {
                    let anime = anime[self.selectedRow]
                    
                    if let aniTitle = anime["title_english"] as? String{
                        popUpView.titleTextView.string = aniTitle
                        
                        if let aniURL = anime["image_url_sml"] as? String{
                            let url = URL(string: aniURL)!
                            let image = NSImage(byReferencing: url)
                            let imageView = NSImageView(image: image)
                            popUpView.iconStackView.addView(imageView, in: NSStackViewGravity.center)
                        }
                        
                        if let hashtag = anime["hashtag"] as? String{
                            // Get rid of the #
                            self.hashtag = String(hashtag.dropFirst())
                            let imageView = popUpView.socialImageView!
                            imageView.image = #imageLiteral(resourceName: "Twitter")
                            //imageView.isEnabled = true
                            
//                            let gestureRec = NSGestureRecognizer(target: self, action: #selector(imageTapped(gestureRec:)))
//                            gestureRec.isEnabled = true
//                            imageView.addGestureRecognizer(gestureRec)
                            //popUpView.iconStackView.addView(imageView, in: NSStackViewGravity.center)
                        }
                    }
                    
                    
                }
            }
            popUpView.dateField.stringValue = self.clickedDate.description
            let menu = sender.menu
            menu?.popUp(positioning: menu?.item(at: 0), at: NSEvent.mouseLocation(), in: nil)
        }
    }
    

    
}

extension WeekViewController:CalendarCellSelectionDelegate{
    func cellViewWasSelected(tableView: NSTableView, row: Int, col: Int) {
        if (self.previousSelectedCellView != nil)
        {
            self.previousSelectedCellView.layer?.backgroundColor = NSColor.clear.cgColor
        }
        let cellView = tableView.view(atColumn: col, row: row, makeIfNecessary: false)
        self.previousSelectedCellView = cellView
        cellView?.layer?.backgroundColor = NSColor.gray.cgColor
        self.selectedRow = row
        self.selectedCol = col
        
        let dayIndex = Int(tableView.tableColumns[col].headerCell.stringValue)! - 1
        let dayDiff = dayIndex - Calendar.current.component(.day, from: self.currentDate)
        self.clickedDate = Calendar.current.date(byAdding: .day, value: dayDiff, to: self.currentDate)
        
    }
}

extension WeekViewController:NSTableViewDataSource
{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 24 // 24 hours in a day
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 40
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
    }
    
}

extension WeekViewController:NSTableViewDelegate
{
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // if this is 1 for monday
        let weekDayColIndex = tableView.tableColumns.index(of: tableColumn!)!
        
        if (weekDayColIndex <= 0)
        {
            return nil
        }
        var view:NSView!
        var title:String = ""
        
        
        // and the currentDate corresponds to 4 for thursday
        let offset = Calendar.current.component(.weekday, from: self.currentDate)
        
        // the actual monday index should be 3 less than whatever the current date is
        let currentEvaluatingDate = Calendar.current.date(byAdding: .day, value: weekDayColIndex, to: self.currentDate)
        let day = Calendar.current.component(.day, from: currentEvaluatingDate!)
        let dayIndex = day// - offset
        
        tableColumn?.headerCell.stringValue = String(describing: day)

        
        if (self.animeSchedule != nil)
        {
            if let animez = self.animeSchedule[dayIndex]
            {
                if (row < animez.count)
                {
                    let anime = animez[row]
                    
                    if let aniTitle = anime["title_english"] as? String{
                        title = aniTitle
                    }
                }
            }
        }
        //}
        if (tableColumn?.identifier == "labelColumnID")
        {
            view = tableView.make(withIdentifier: "labelCellViewID", owner: nil) as! NSTableCellView
            (view as! NSTableCellView).textField?.stringValue = String(describing:(row+1))
        }
        else
        {
            view = tableView.make(withIdentifier: "dayCellViewID", owner: nil)
            (view as! NSTableCellView).textField?.stringValue = title
        }
        
        return view
    }
}

extension WeekViewController:ImageViewDelegate{
    func imageViewClicked(imageView: NSImageView) {
        print("Image view clicked!!!")
        if (imageView.image == #imageLiteral(resourceName: "Twitter"))
        {
            let urlString = "https://twitter.com/hashtag/" + self.hashtag
            if let url = URL(string:urlString){
                NSWorkspace.shared().open(url)
            }
        }
    }
}
