//
//  Chat.swift
//  SimpleChat
//
//  Created by Manvir Singh on 03/05/20.
//  Copyright © 2020 Manvir Singh. All rights reserved.
//

import Foundation
import UIKit

enum MessageType :String {
    
    case image = "image"
    case text = "text"
    
}


struct Chat {
    
    var date :Date
    var messages :[Messages]
    
    
}


struct  Messages {
    
    var type :MessageType
    var message :String
    var image :UIImage?
    var time :Date
    var senderID :String
    
}

extension Date {
    static func randomDate(range: Int) -> Date {
        // Get the interval for the current date
        let interval =  Date().timeIntervalSince1970
        // There are 86,400 milliseconds in a day (ignoring leap dates)
        // Multiply the 86,400 milliseconds against the valid range of days
        let intervalRange = Double(86_400 * range)
        // Select a random point within the interval range
        let random = Double(arc4random_uniform(UInt32(intervalRange)) + 1)
        // Since this can either be in the past or future, we shift the range
        // so that the halfway point is the present
        let newInterval = interval + (random - (intervalRange / 2.0))
        // Initialize a date value with our newly created interval
        return Date(timeIntervalSince1970: newInterval)
    }
}
