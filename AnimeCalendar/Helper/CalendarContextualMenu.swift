//
//  CalendarContextualMenu.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 10/6/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa

class CalendarContextualMenu: NSObject {
    static let shared = CalendarContextualMenu()
    
    var menu:NSMenu!
    
//    init(tableView:NSTableView) {
//        super.init()
//        self.tableView = tableView
//    }

    
    func createMenu(itemView:NSView, target:AnyObject){
        // create a new menu from scratch and add it to the app's menu bar
        
        let menu = NSMenu(title: "Custom")
        let menuItem = NSMenuItem(title: "Foo", action: nil, keyEquivalent: "Foo")
        menuItem.view = itemView
        menuItem.isEnabled = true
        //menuItem.target = target
        menu.addItem(menuItem)
        self.menu = menu
        // return menu
        
//        NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Custom", @"")
//            action:NULL
//            keyEquivalent:@""];
//        NSMenu *newMenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Custom", @"")];
//        newItem.enabled = YES;
//        newItem.submenu = newMenu;
//        [[NSApp mainMenu] insertItem:newItem atIndex:3];
        
    }

}
