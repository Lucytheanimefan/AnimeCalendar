//
//  WeekViewController.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 9/23/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa

class WeekViewController: NSViewController {
    
    var newAniList:NewAnimeList! = NewAnimeList.sharedInstance
    
    var animeSchedule:[Int:[[String:Any]]]!
    
    @IBOutlet weak var tableView: CustomTableView!
    var previousSelectedCellView:NSView!
    
    lazy var weekDay = {
        return Calendar.current.component(.weekday, from: Date())
    }()
    
    @IBOutlet weak var currentMonthYear: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.selectionHighlightStyle = .none
        self.tableView.cellSelectionDelegate = self
        self.setUpMonthlyAnime()
        
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
        
        // Display the data in anime day tableview
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
    
}

extension WeekViewController:NSTableViewDelegate
{
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view:NSView!
        var title:String = ""
        let weekDayColIndex = tableView.tableColumns.index(of: tableColumn!)!
        //print(self.weekDayDict())
        if let dayIndex = self.weekDayDict()[weekDayColIndex]{
            
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
        }
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
