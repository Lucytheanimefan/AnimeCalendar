//
//  ViewController.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 9/16/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa
import AppKit

class ViewController: NSViewController {
    
    let calendar = Calendar.current
    
    var days = [Int]()

    @IBOutlet weak var containerView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func daysInMonth() -> Double{
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        var components = DateComponents()
        components.year = year
        components.month = month
        let newDate = calendar.date(from: components)
        let range = calendar.range(of: .day, in: .month, for: newDate!)!
        let numDays = range.count
        self.days = Array(1...numDays)
        return Double(numDays)
    }
    
}



