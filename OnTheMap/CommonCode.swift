//
//  OnTheMapConstants.swift
//  OnTheMap
//
//  Created by Mohammed Ibrahim on 10/22/16.
//  Copyright © 2016 myw. All rights reserved.
//

import Foundation


struct udacityUser
{
        static var userID = ""
        static var sessionID = "sessionID"
        static var firstName = ""
        static var lastName = ""
        static var userName = "userName"
        static var objectId = ""
        static var mediaURL = ""
}

struct parseStudentLoc
{
        static var studentLocations: [[String:AnyObject]]!
}


struct udMethods
{
    static var authenticate = "https://www.udacity.com/api/session"
    static var getUserDetails = "https://www.udacity.com/api/users/\(udacityUser.userID)"
    static var getStudentLocations = "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt"
    static var postStudentLocations = "https://parse.udacity.com/parse/classes/StudentLocation"
    static var updateStudentLocations = "https://parse.udacity.com/parse/classes/StudentLocation/\(udacityUser.objectId)"
}

struct udParameter {
    static let applicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    
    static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
}


