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
    
    init(dictionary: [String : AnyObject])
    {
        let firstName = dictionary["firstName"] as! String
        let lastName = dictionary["lastName"] as! String
        self.name = "\(firstName) \(lastName)"
        self.location = dictionary["mapString"] as! String
        self.mediaURL = dictionary["mediaURL"] as! String
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

