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
    
    convenience init(window:NSWindow) {
        self.init()
        self.window = window
    }
    
    func updateAuthStatusToAccessEventStore(){
        let authStatus = EKEventStore.authorizationStatus(for: EKEntityType.reminder)
        
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

}
