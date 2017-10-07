//
//  CalendarPopUpMenuView.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 10/7/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa

class CalendarPopUpMenuView: NSView {
    
    @IBOutlet weak var iconStackView: NSStackView!
    
    @IBOutlet var titleTextView: NSTextView!
    
    @IBOutlet weak var dateField: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
