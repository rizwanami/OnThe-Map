//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Mohammed Ibrahim on 10/23/16.
//  Copyright © 2016 myw. All rights reserved.
//

import Foundation
import UIKit

class tableView: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var pin: UIBarButtonItem!
    
    @IBOutlet weak var Refresh: UIBarButtonItem!
    
    @IBOutlet weak var Logout: UIBarButtonItem!
    let studentDetails =  studentInformation.studentInformations
    
    
    override func viewDidLoad()
    {
        
        table.dataSource = self
        table.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        table.reloadData()
    }
    
    @IBAction func pin(_ sender: AnyObject) {
        
        if  udacityUser.objectId == ""
        {
            performSegue(withIdentifier: "studentLocation", sender: self)
        } else {
            let alert = UIAlertController()
            alert.title = "Do you want to overwrite"
            alert.message = ""
            
            let continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.default) {
                action in self.performSegue(withIdentifier: "studentLocation", sender: self)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
                action in alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(continueAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func refreshButton(_ sender: AnyObject) {
        let studentLocation = UdacityClient()
        studentLocation.getStudentLocations{(success, error) in
            if success == true {
                performUIUpdatesOnMain{
                    self.uiEnable(Status: true)
                }
            } else if (error == "The Internet connection appears to be offline.") {
                self.showAlert(alerttitle: "Unable to Connect to Server", alertmessage: "Check your internet connection and try again.")
            } else {
                self.uiEnable(Status: true)
                print(error)
            }
        }
        
    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        let deletingCookies = UdacityClient()
        deletingCookies.logout(completionHandlerForLogOut:{(success, error) in
            if success == true {
                
                self.dismiss(animated: true, completion: nil)
            } else {
                self.uiEnable(Status: true)
                print("logOut Error is: \(error)")
            }
        })
        
    }
    
    func uiEnable(Status : Bool) {
        pin.isEnabled = Status
        Logout.isEnabled = Status
        Refresh.isEnabled = Status
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return studentDetails.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "details", for: indexPath) as! tableViewCell
        
        let student = studentDetails[indexPath.row]
        
        cell.title.text = student.name
        cell.location.text = student.location
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let student = studentDetails[indexPath.row]
        let mediaURLString = student.mediaURL
        
        if let mediaURL = URL(string: mediaURLString) {
            if UIApplication.shared.canOpenURL(mediaURL) {
                UIApplication.shared.openURL(mediaURL)
            } else {
                self.showAlert(alerttitle:"Incomplete URL", alertmessage: "Media URL [\(mediaURLString)] is incorrect or not fully formed")
            }
            
        } else {
            
            self.showAlert(alerttitle: "Bad Media URL", alertmessage: "Media URL [\(mediaURLString)] is invalid")
        }
        
    }
    
    
    func showAlert(alerttitle: String, alertmessage: String) {
        let alertController = UIAlertController(title: alerttitle, message: alertmessage as String, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            action in alertController.dismiss(animated: true, completion: nil)
            
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
