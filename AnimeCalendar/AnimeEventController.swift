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
    let eventStore = EKEventStore()
    
    func updateAuthStatusToAccessEventStore(){
        let authStatus = EKEventStore.authorizationStatus(for: EKEntityType.reminder)
        
        
        
    }

}
