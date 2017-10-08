//
//  CalendarPopUpMenuView.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 10/7/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa

protocol ImageViewDelegate{
    func imageViewClicked(imageView:NSImageView)
}

class CalendarPopUpMenuView: NSView {
    
    @IBOutlet weak var iconStackView: NSStackView!
    
    @IBOutlet var titleTextView: NSTextView!
    
    @IBOutlet weak var dateField: NSTextField!
    
    @IBOutlet weak var socialImageView: NSImageView!
    
    var imageViewDelegate:ImageViewDelegate!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    @IBAction func clickSocialImageView(_ sender: NSImageView) {
        print("-----clickSocialImageView")
        self.imageViewDelegate.imageViewClicked(imageView: sender)
    }
    
}
