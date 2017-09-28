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
    var grantedAccess = [EKEntityType.event: false, EKEntityType.reminder: false]
    var window:NSWindow?
    var entityType:EKEntityType = EKEntityType.reminder
    
    var reminderCalendar:EKCalendar!
    var eventCalendar:EKCalendar!
    
    lazy var sources: [EKSource] = {
        var finalSources = [String]()
        var finalCalendars = [EKSource]()
        for source in self.eventStore.sources
        {
            if (!finalSources.contains(source.title))
            {
                finalSources.append(source.title)
                finalCalendars.append(source)
            }
        }
//        print("Source count: ")
//        print(finalCalendars.count)
//        print(finalSources)
        return finalCalendars
    }()
    
    convenience init(window:NSWindow) {
        self.init()
        self.window = window
    }
    
    func updateAuthStatus(){
        self.updateAuthStatusToAccessEventStore(entityType: EKEntityType.reminder)
        self.updateAuthStatusToAccessEventStore(entityType: EKEntityType.event)
    }
    
    func createCalendars(){
        if (self.grantedAccess[EKEntityType.event])!
        {
            self.createEventCalendar()
        }
        if (self.grantedAccess[EKEntityType.reminder])!
        {
            self.createReminderCalendar()
        }
    }
    
    func createReminderCalendar(){
        self.reminderCalendar = self.createCalendar(entityType: EKEntityType.reminder)
    }
    
    func createEventCalendar(){
        self.eventCalendar = self.createCalendar(entityType: EKEntityType.event)
    }
    
    func sourceToCalendars() -> [String:[EKCalendar]]
    {
        var dict = [String:[EKCalendar]]()
        for cal in eventCalendars(){
            let sourceTitle = cal.source.title
            if (dict[sourceTitle] == nil)
            {
                dict[sourceTitle] = [cal]
            }
            else
            {
                dict[sourceTitle]?.append(cal)
            }
        }
        return dict
    }
    
    func eventCalendars() -> [EKCalendar]{
        return self.eventStore.calendars(for: .event)
        //return calendars(entityType: EKEntityType.event, filterMatch: "anime")
    }
    
    func reminderCalendars() -> [EKCalendar]{
        return calendars(entityType: EKEntityType.reminder, filterMatch: "anime")
    }
    
    func calendars(entityType:EKEntityType, filterMatch:String) -> [EKCalendar]
    {
        let calendars = self.eventStore.calendars(for: entityType)
        let predicate = NSPredicate.init(format: "title contains[c] %@", filterMatch)
        let filtered = (calendars as NSArray).filtered(using: predicate)
        return filtered as! [EKCalendar]
    }
    
    private func updateAuthStatusToAccessEventStore(entityType:EKEntityType){
        let authStatus = EKEventStore.authorizationStatus(for: entityType)
        
        switch authStatus {
        case EKAuthorizationStatus.denied, EKAuthorizationStatus.restricted:
            print("Denied/restricted!")
            self.grantedAccess[entityType] = false
            self.eventAuthFailAlert()
            break
        case EKAuthorizationStatus.authorized:
            print("Authorized!")
            self.grantedAccess[entityType] = true
            break
        case EKAuthorizationStatus.notDetermined:
            print("Not determined EKAuth status")
            self.eventStore.requestAccess(to: entityType, completion: { (granted, error) in
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
    
    private func eventAuthFailAlert(){
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
    
    private func createCalendar(entityType:EKEntityType) -> EKCalendar?{
        let calendarTitle = "Anime"
        let calendars = self.eventStore.calendars(for: entityType)
        let predicate = NSPredicate.init(format: "title matches %@", calendarTitle)
        let filtered = (calendars as NSArray).filtered(using: predicate)
        var calendar:EKCalendar!
        if (filtered.count > 0)
        {
            calendar = filtered.first as! EKCalendar
        }
        else
        {
            // Create the calendar if it doesn't exist
            
            calendar = EKCalendar(for: entityType, eventStore: self.eventStore)
            calendar.title = "Anime"
            if (entityType == EKEntityType.event)
            {
                for source in self.eventStore.sources
                {
                    if (source.sourceType == EKSourceType.calDAV && source.title == "iCloud")
                    {
                        calendar.source = source
                        break
                    }
                }
            }
            else
            {
                calendar.source = self.eventStore.defaultCalendarForNewEvents.source
            }
            
            // Save the calendar
            do
            {
                try self.eventStore.saveCalendar(calendar, commit: true)
            }
            catch
            {
                print("Failed to save calendar due to: ")
                print(error)
            }
        }
        return calendar
    }

}
