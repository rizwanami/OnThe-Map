//
//  studentInformation.swift
//  OnTheMap
//
//  Created by Mohammed Ibrahim on 10/25/16.
//  Copyright © 2016 myw. All rights reserved.
//

import Foundation
import UIKit

struct studentInformation
{
    let name: String
    let location: String
    let mediaURL: String
    let uniqueKey : String
    
    init(dictionary: [String : AnyObject])
    {
        let firstName = dictionary["firstName"] as! String
        
        if let lastName = dictionary["lastName"] as? String
        {
            self.name = "\(firstName) \(lastName)"
        } else {
            self.name = firstName
        }
        
        if let mapString = dictionary["mapString"] as? String {
            self.location = mapString
        } else {
            self.location = ""
        }
        if let mediaURL = dictionary["mediaURL"] as? String {
            self.mediaURL = mediaURL
        } else {
            self.mediaURL = "www.google.com"
        }
        if let uniqueKey = dictionary[ "uniqueKey"] as? String {
            self.uniqueKey = uniqueKey
        } else {
            self.uniqueKey = ""
        }
    }
}

extension studentInformation
{
    static var studentInformations: [studentInformation] {
        
        var studentArray: [studentInformation] = []
        
        for d in parseStudentLoc.studentLocations! {
            if d["firstName"] != nil {
                
                studentArray.append(studentInformation(dictionary: d))
            }
        }
        
        return studentArray
    }
}

