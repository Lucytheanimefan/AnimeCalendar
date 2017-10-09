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
    
    
    @IBOutlet weak var socialImageView: CustomImageView!
    
    var imageViewDelegate:ImageViewDelegate!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.socialImageView.imageDelegate = self
        // Drawing code here.
    }
    
//    @IBAction func clickSocialImageView(_ sender: NSImageView) {
//        Swift.print("-----clickSocialImageView")
//        self.imageViewDelegate.imageViewClicked(imageView: sender)
//    }
}

extension CalendarPopUpMenuView:ImageDelegate{
    func imageClicked() {
        print("IMAGE CLICKED")
        self.imageViewDelegate.imageViewClicked(imageView: socialImageView)
    }
}
