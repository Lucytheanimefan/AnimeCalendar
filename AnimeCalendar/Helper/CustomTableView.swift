//
//  CustomTableView.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 9/26/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa

protocol CalendarCellSelectionDelegate{
    func cellViewWasSelected(tableView:NSTableView, row:Int, col:Int)
}

class CustomTableView: NSTableView {
    
    var cellSelectionDelegate:CalendarCellSelectionDelegate!// = CalendarCellSelectionDelegate()

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    

    
    override func mouseDown(with event: NSEvent) {
        let point = self.convert(event.locationInWindow, from: nil)
        let row = self.row(at: point)
        let col = self.column(at: point)
        super.mouseDown(with: event)
        self.cellSelectionDelegate.cellViewWasSelected(tableView: self, row: row, col: col)
        
    }
    
    func clickCell(row:Int, col:Int){
        self.cellSelectionDelegate.cellViewWasSelected(tableView: self, row: row, col: col)
    }
    
}
