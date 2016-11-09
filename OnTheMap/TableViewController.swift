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
    let studentDetails = studentInformation.studentInformations
    
    override func viewDidLoad()
    {
        //Assign Data Source and Delegate
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
            let cancelAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.default) {
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
                
                //some message here
                performUIUpdatesOnMain{
                    let alert = UIAlertController()
                    alert.title = "Unable Connect To Server"
                    alert.message = "Check your internet connection"
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        action in alert.dismiss(animated: true, completion: nil)
                    }
                    
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    
                }
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
                
                self.performSegue(withIdentifier: "logOut", sender: self)
                
                
                
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
        
        cell.textLabel?.text = student.name
        cell.title.text = student.location
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let student = studentDetails[indexPath.row]
        let mediaURL = student.mediaURL
        print(mediaURL)
        
        UIApplication.shared.openURL(URL(string: mediaURL)!)
        
    }
    
    
}