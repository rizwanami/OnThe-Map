//
//  ViewController.swift
//  OnTheMap
//
//  Created by Mohammed Ibrahim on 10/16/16.
//  Copyright © 2016 myw. All rights reserved.
//

import UIKit

class LoginController: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var emailID: UITextField!
    @IBOutlet weak var Password: UITextField!
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var activityBar: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailID.delegate = self
        Password.delegate = self
        activityBar.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        self.activityBar.isHidden = true
    }
    
    
    
    
    @IBAction func login(_ sender: AnyObject) {
        
        activityBar.isHidden = true
        activityBar.stopAnimating()
        
        if !isValidEmail(EmailAddress: emailID.text!)
        {
            self.showAlert(alertmessage: "Invalid Email Address")
        }
        
        self.emailID.resignFirstResponder()
        self.Password.resignFirstResponder()
        
        self.activityBar.isHidden = false
        self.activityBar.startAnimating()
        let httpBody = "{\"udacity\": {\"username\": \"\(self.emailID.text!)\", \"password\": \"\(self.Password.text!)\"}}"
        let udClient = UdacityClient()
        let loginHandler = udClient.postApi(method: udMethods.authenticate, httpBody: httpBody, range: 5, completionHandlerForPost:
            { (userdata, error) in
                guard error == "" else
                {
                    self.activityBar.isHidden = true
                    self.activityBar.stopAnimating()
                    
                    print(error)
                    self.showAlert(alertmessage: error)
                    return
                }
                
                guard let data = userdata as? NSDictionary else
                {
                    self.activityBar.isHidden = true
                    self.activityBar.stopAnimating()
                    
                    print("Could not get data")
                    self.showAlert(alertmessage: "Error Fetching Data")
                    return
                }
                
                guard let accountDetails = data["account"] as? NSDictionary else
                {
                    self.activityBar.isHidden = true
                    self.activityBar.stopAnimating()
                    
                    print("Missing account details")
                    self.showAlert(alertmessage: "Missing Account Details")
                    return
                }
                
                guard let userId = accountDetails["key"] as? String else
                {
                    self.activityBar.isHidden = true
                    self.activityBar.stopAnimating()
                    
                    print("Missing User ID")
                    self.showAlert(alertmessage: "Missing User ID")
                    return
                }
                
                udacityUser.userID = userId
                
                guard let sessionDetails = data["session"] as? NSDictionary else
                {
                    self.activityBar.isHidden = true
                    self.activityBar.stopAnimating()
                    
                    self.showAlert(alertmessage: "Missing Session Details")
                    return
                }
                
                guard let sessionID = sessionDetails["id"] as? String else
                {
                    self.activityBar.isHidden = true
                    self.activityBar.stopAnimating()
                    
                    self.showAlert(alertmessage: "cant get session id")
                    return
                }
                udacityUser.sessionID = sessionID
                
                print("Before getUserDetails")
                udClient.get(method: udMethods.getUserDetails, range: 5, completionHandlerForGet:{ ( UserDetail, error) in
                    print("Inside closure of getUserDetails")
                    guard error == "" else {
                        self.activityBar.isHidden = true
                        self.activityBar.stopAnimating()
                        
                        self.showAlert(alertmessage: "This is the error for getting UserDetail \(error)")
                        return
                    }
                    guard let data = UserDetail as? NSDictionary else {
                        self.activityBar.isHidden = true
                        self.activityBar.stopAnimating()
                        
                        self.showAlert(alertmessage: "There is no Data in UserDeatil \(UserDetail)")
                        return
                    }
                    print(data)
                    
                    guard let user = data["user"] as? [String: AnyObject] else {
                        self.activityBar.isHidden = true
                        self.activityBar.stopAnimating()
                        
                        self.showAlert(alertmessage: "There is no data found in user array in data dictionary")
                        return
                    }
                    guard let firstName = user["first_name"] as? String else {
                        self.activityBar.isHidden = true
                        self.activityBar.stopAnimating()
                        self.showAlert(alertmessage: "There is no first name founnd")
                        return
                    }
                    guard let lastName = user["last_name"] as? String  else
                    {
                        self.activityBar.isHidden = true
                        self.activityBar.stopAnimating()
                        self.showAlert(alertmessage: "There is no last name is found")
                        return
                    }
                    
                    udacityUser.firstName = firstName
                    udacityUser.lastName = lastName
                    let userName = "\(firstName) \(lastName)"
                    udacityUser.userName = userName
                    
                    self.getStudentInformation(udClient: udClient)
                    
                    //self.showAlert(alertmessage: "Appication ID is Invalid ")
                    print("End of getUserDetails")
                })
                print("After getUserDetails")
        })
    }
    
    
    func isValidEmail(EmailAddress:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: EmailAddress)
        return result
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.emailID.resignFirstResponder()
        self.Password.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func showAlert(alertmessage: String) {
        let alertController = UIAlertController(title: "Login Error!", message: alertmessage as String, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            action in alertController.dismiss(animated: true, completion: nil)
            
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getStudentInformation(udClient : UdacityClient) {
        //
        udClient.getStudentLocations(completionHandlerForLocations: { (sucess,locationError) in
            if sucess == true && (locationError == nil || locationError == "")
            {
                self.activityBar.isHidden = false
                self.activityBar.isAnimating
                self.displayTabView()
            }
            else
            {
                self.activityBar.isHidden = true
                self.activityBar.stopAnimating()
                self.showAlert(alertmessage: "Unable to fetch student locations \(locationError)")
                //print("This is invalid application ID : \(locationError) ")
            }
        })
        
    }
    func UIEnable(status : Bool) {
        emailID.isEnabled = status
        Password.isEnabled = status
        loginButton.isEnabled = status
        activityBar.isHidden = status
    }
    
    func displayTabView() {
        
        performUIUpdatesOnMain {
            let tabViewController = self.storyboard!.instantiateViewController(withIdentifier: "TabView") as! UITabBarController
            self.present(tabViewController, animated: true, completion: nil)
        }
    }
    
}





