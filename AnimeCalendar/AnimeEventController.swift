//
//  AnimeEventController.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 9/20/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Cocoa
import EventKit

class AnimeEventController: NSObject {
    
    //static let shared = AnimeEventController()
    
    let eventStore = EKEventStore()
    var isAccessToEventStoreGranted = false
    var window:NSWindow?
    var entityType:EKEntityType = EKEntityType.reminder
    
    lazy var calendar:EKCalendar? = {
        let calendarTitle = "Anime"
        let calendars = self.eventStore.calendars(for: self.entityType)
        let predicate = NSPredicate.init(format: "title matches %@", calendarTitle)
        let filtered = (calendars as NSArray).filtered(using: predicate)
        
        var calendar:EKCalendar!
        if (filtered.count > 0)
        {
            calendar = filtered.first as! EKCalendar
        }
        else
        {
            calendar = EKCalendar(for: self.entityType, eventStore: self.eventStore)
            calendar.title = "Anime"
            calendar.source = self.eventStore.defaultCalendarForNewEvents.source
            
            // Create the calendar if it doesn't exist
            do{
                try self.eventStore.saveCalendar(calendar, commit: true)
            }
            catch
            {
                print(error)
            }
        }
        return calendar
    }()
    
    convenience init(window:NSWindow) {
        self.init()
        self.window = window
    }
    
    func updateAuthStatusToAccessEventStore(eventType:Bool){
        var type:EKEntityType = EKEntityType.reminder
        if (eventType){ type = EKEntityType.event}

        let authStatus = EKEventStore.authorizationStatus(for: type)
        
        switch authStatus {
        case EKAuthorizationStatus.denied, EKAuthorizationStatus.restricted:
            print("Denied/restricted!")
            self.isAccessToEventStoreGranted = false
            self.eventAuthFailAlert()
            break
        case EKAuthorizationStatus.authorized:
            print("Authorized!")
            self.isAccessToEventStoreGranted = true
            break
        case EKAuthorizationStatus.notDetermined:
            print("Not determined EKAuth status")
            self.eventStore.requestAccess(to: EKEntityType.reminder, completion: { (granted, error) in
                if (error != nil)
                {
                    print(error.debugDescription)
                    self.eventAuthFailAlert()
                }
                else if (granted)
                {
                    print("Granted :) ")
                }
            })
        default:
            print("Default case do nothing")
        }
    }
    
    func eventAuthFailAlert(){
        let alert = NSAlert()
        alert.messageText = "Access denied."
        alert.informativeText = "This app doesn't have access to your Reminders."
        if (self.window != nil){
            alert.beginSheetModal(for: self.window!) { (response) in
                if (response == NSModalResponseOK){
                    print("Response is OK")
                }
            }
        }
        else{
            let response = alert.runModal()
        }
    }
    
//    func getCalendar(){
//        let calendarTitle = "Anime"
//        let calendars = self.eventStore.calendars(for: self.entityType)
//        let predicate = NSPredicate.init(format: "title matches %@", calendarTitle)
//        let filtered = (calendars as NSArray).filtered(using: predicate)
//        
//        if (filtered.count > 0)
//        {
//            self.calendar = filtered.first as! EKCalendar
//        }
//        else
//        {
//            self.calendar = EKCalendar(for: self.entityType, eventStore: self.eventStore)
//            self.calendar.title = "Anime"
//            self.calendar.source = self.eventStore.defaultCalendarForNewEvents.source
//            
//            // Create the calendar if it doesn't exist
//            do{
//                try self.eventStore.saveCalendar(self.calendar, commit: true)
//            }
//            catch
//            {
//            }
//        }
//    }

}
