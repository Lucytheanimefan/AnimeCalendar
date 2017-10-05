//
//  WindowController.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 9/23/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    
    @IBOutlet weak var toolBar: NSToolbar!
    
    let CalendarHeaderToolbarID = "calendarToolBarID"
    
    let calendarTypes = ["Day", "Week", "Month", "Year"]
    
    @IBOutlet var windowBarView: NSView!
    
    let dayVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "dayViewControllerID") as! DayViewController
    let weekVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "weekViewControllerID") as! WeekViewController
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        self.toolBar.allowsUserCustomization = true
        self.toolBar.autosavesConfiguration = true
        self.toolBar.displayMode = .iconOnly
        
        self.window?.titleVisibility = .hidden
        
        if let vc = self.contentViewController as? ViewController{
            vc.addChildViewController(dayVC)
            vc.addChildViewController(weekVC)
        }
    }
    
    @IBAction func switchCalendarViews(_ sender: NSSegmentedControl) {
        let calendarType = self.calendarTypes[sender.selectedSegment]
        if let vc = self.contentViewController as? ViewController{
            for sView in vc.containerView.subviews{
                sView.removeFromSuperview()
            }
            
            if (calendarType == "Day")
            {
                self.dayVC.view.frame = vc.containerView.bounds
                vc.containerView.addSubview(self.dayVC.view)
            }
            else if (calendarType == "Week")
            {
                self.weekVC.view.frame = vc.containerView.bounds
                vc.containerView.addSubview(self.weekVC.view)
            }
        }
    }
    
//    @IBAction func switchViews(_ sender: NSButton) {
//        if let vc = self.contentViewController as? ViewController{
//            for sView in vc.containerView.subviews{
//                sView.removeFromSuperview()
//            }
//            
//            if (sender.title == "Day")
//            {
//                self.dayVC.view.frame = vc.containerView.bounds
//                vc.containerView.addSubview(self.dayVC.view)
//            }
//            else if (sender.title == "Week")
//            {
//                self.weekVC.view.frame = vc.containerView.bounds
//                vc.containerView.addSubview(self.weekVC.view)
//            }
//        }
//    }
    
    @IBAction func showCalendarsSideView(_ sender: NSButton) {
        if let vc = self.contentViewController as? ViewController{
            vc.calendarSideView.isHidden = !vc.calendarSideView.isHidden
        }
    }
    
    func customToolbarItem(itemForItemIdentifier itemIdentifier: String, label: String, paletteLabel: String, toolTip: String, target: AnyObject, itemContent: AnyObject, action: Selector?, menu: NSMenu?) -> NSToolbarItem? {
        
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        
        toolbarItem.label = label
        toolbarItem.paletteLabel = paletteLabel
        toolbarItem.toolTip = toolTip
        toolbarItem.target = target
        toolbarItem.action = action
        
        // Set the right attribute, depending on if we were given an image or a view.
        if (itemContent is NSImage) {
            let image: NSImage = itemContent as! NSImage
            toolbarItem.image = image
        }
        else if (itemContent is NSView) {
            let view: NSView = itemContent as! NSView
            toolbarItem.view = view
        }
        else {
            assertionFailure("Invalid itemContent: object")
        }
        
        /* If this NSToolbarItem is supposed to have a menu "form representation" associated with it
         (for text-only mode), we set it up here.  Actually, you have to hand an NSMenuItem
         (not a complete NSMenu) to the toolbar item, so we create a dummy NSMenuItem that has our real
         menu as a submenu.
         */
        // We actually need an NSMenuItem here, so we construct one.
        let menuItem: NSMenuItem = NSMenuItem()
        menuItem.submenu = menu
        menuItem.title = label
        toolbarItem.menuFormRepresentation = menuItem
        
        return toolbarItem
    }

}

extension WindowController:NSToolbarDelegate {
    /**
     NSToolbar delegates require this function.
     It takes an identifier, and returns the matching NSToolbarItem. It also takes a parameter telling
     whether this toolbar item is going into an actual toolbar, or whether it's going to be displayed
     in a customization palette.
     */
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        var toolbarItem: NSToolbarItem = NSToolbarItem()
        
        /* We create a new NSToolbarItem, and then go through the process of setting up its
         attributes from the master toolbar item matching that identifier in our dictionary of items.
         */
        if (itemIdentifier == CalendarHeaderToolbarID) {
            // 1) Font style toolbar item.
            toolbarItem = customToolbarItem(itemForItemIdentifier: CalendarHeaderToolbarID, label: "Browser Header", paletteLabel:"Browser header", toolTip: "Browser header", target: self, itemContent: self.windowBarView, action: nil, menu: nil)!
        }
        
        return toolbarItem
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        
        return [CalendarHeaderToolbarID]
        
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        
        return [ CalendarHeaderToolbarID,
                 NSToolbarSpaceItemIdentifier,
                 NSToolbarFlexibleSpaceItemIdentifier,
                 NSToolbarPrintItemIdentifier ]
    }
}
