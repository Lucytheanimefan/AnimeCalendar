//
//  CustomImageView.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 10/8/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa
protocol ImageDelegate{
    func imageClicked()
}

class CustomImageView: NSImageView {
    var imageDelegate:ImageDelegate!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func mouseUp(with event: NSEvent) {
        self.imageDelegate.imageClicked()
    }
    
    override func performClick(_ sender: Any?) {
        
    }
    
    override func print(_ sender: Any?) {
        
    }
    
}
