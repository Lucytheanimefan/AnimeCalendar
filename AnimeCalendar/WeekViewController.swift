//
//  WeekViewController.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 9/23/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa

class WeekViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
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
        if (tableColumn?.identifier == "labelColumnID")
        {
            view = tableView.make(withIdentifier: "labelCellViewID", owner: nil) as! NSTableCellView
            (view as! NSTableCellView).textField?.stringValue = String(describing:(row+1))
        }
        else
        {
            view = tableView.make(withIdentifier: "dayCellViewID", owner: nil)
            (view as! NSTableCellView).textField?.stringValue = "Week day"
        }
        
        return view
    }
}
