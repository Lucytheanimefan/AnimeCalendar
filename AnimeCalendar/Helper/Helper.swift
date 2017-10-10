//
//  Helper.swift
//  AnimeCalendar
//
//  Created by Lucy Zhang on 10/9/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import Foundation
import AppKit

func stringToHTML(description:String) -> NSTextStorage{
    
    let html = description.data(using: .utf8)
    let attributedString = NSAttributedString(html: html!, options: [String : Any](), documentAttributes: nil)
    let storage = NSTextStorage(attributedString: attributedString!)
    return storage
    
}
