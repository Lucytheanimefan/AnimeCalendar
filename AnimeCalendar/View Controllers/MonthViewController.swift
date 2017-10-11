//
//  MonthViewController.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 10/10/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa

class MonthViewController: NSViewController {
    @IBOutlet weak var monthTableView: CustomTableView!
    var previousSelectedCellView:NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.monthTableView.cellSelectionDelegate = self as! CalendarCellSelectionDelegate
        // Do view setup here.
    }
    
}

extension MonthViewController:CalendarCellSelectionDelegate{
    func cellViewWasSelected(tableView:NSTableView, row:Int, col:Int)
    {
        if (self.previousSelectedCellView != nil)
        {
            self.previousSelectedCellView.layer?.backgroundColor = NSColor.clear.cgColor
        }
        let cellView = self.monthTableView.view(atColumn: col, row: row, makeIfNecessary: false)
        self.previousSelectedCellView = cellView
        cellView?.layer?.backgroundColor = NSColor.gray.cgColor
        
    }
}

extension MonthViewController:NSTableViewDelegate{
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return nil
    }
}

extension MonthViewController:NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 5
    }
    
}
