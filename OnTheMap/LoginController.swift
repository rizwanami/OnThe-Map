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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        emailID.delegate = self
        Password.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @IBAction func login(_ sender: AnyObject) {
        if !isValidEmail(EmailAddress: emailID.text!)
        {
            self.showAlert(alertmessage: "Invalid Email Address")
        }
        self.emailID.resignFirstResponder()
        self.Password.resignFirstResponder()
        
        let httpBody = "{\"udacity\": {\"username\": \"\(self.emailID.text!)\", \"password\": \"\(self.Password.text!)\"}}"
        let udClient = UdacityClient()
        let loginHandler = udClient.postApi(method: udMethods.authenticate, httpBody: httpBody, range: 5, completionHandlerForPost:
        { (userdata, error) in
            guard error == "" else
            {
                print(error)
                self.showAlert(alertmessage: error)
                return
            }
            
            guard let data = userdata as? NSDictionary else
            {
                print("Could not get data")
                self.showAlert(alertmessage: "Error Fetching Data")
                return
            }
            
            guard let accountDetails = data["account"] as? NSDictionary else
            {
                print("Missing account details")
                self.showAlert(alertmessage: "Missing Account Details")
                return
            }
            
            guard let userId = accountDetails["key"] as? String else
            {
                print("Missing User ID")
                self.showAlert(alertmessage: "Missing User ID")
                return
            }
            
            udacityUser.userID = userId
            
            guard let sessionDetails = data["session"] as? NSDictionary else
            {
                self.showAlert(alertmessage: "Missing Session Details")
                return
            }
            
            guard let sessionID = sessionDetails["id"] as? String else
            {
                self.showAlert(alertmessage: "cant get session id")
                return
            }
            udacityUser.sessionID = sessionID
            
            udClient.get(method: udMethods.getUserDetails, range: 5, completionHandlerForGet:{ ( UserDetail, error) in
                guard error == "" else {
                    self.showAlert(alertmessage: "This is the error for getting UserDetail \(error)")
                    return
                }
                guard let data = UserDetail as? NSDictionary else {
                    self.showAlert(alertmessage: "There is no Data in UserDeatil \(UserDetail)")
                    return
                }
                print(data)
            
                guard let user = data["user"] as? [String: AnyObject] else {
                    self.showAlert(alertmessage: "There is no data found in user array in data dictionary")
                    return
                }
                guard let firstName = user["first_name"] as? String else {
                    self.showAlert(alertmessage: "There is no first name founnd")
                    return
                }
                guard let lastName = user["last_name"] as? String  else
                {
                    self.showAlert(alertmessage: "There is no last name is found")
                    return
            
                }
                udacityUser.firstName = firstName
                udacityUser.lastName = lastName
                let userName = "\(firstName) \(lastName)"
                udacityUser.userName = userName
                })
            //Fetch the Student Information of all student in the network
            self.getStudentInformation(udClient: udClient)
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

    //Display Login/Connectivity Error
    func showAlert(alertmessage: String) {
        let alertController = UIAlertController(title: "Login Error!", message: alertmessage as String, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            action in alertController.dismiss(animated: true, completion: nil)

        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getStudentInformation(udClient : UdacityClient) {
        udClient.get(method: udMethods.getUserDetails,range: 5 ,completionHandlerForGet: { (data, error) in
            guard error == "" else
            {
                self.showAlert(alertmessage: error)
                return
            }
            guard let udData = data as? NSDictionary else
            {
                self.showAlert(alertmessage: "Error Converting Student Data")
                return
            }
            
            guard let user = udData["user"] as? [String: AnyObject] else
            {
                self.showAlert(alertmessage: "User not found")
                return
            }
            
            guard let firstName = user["first_name"] as? String else
            {
                self.showAlert(alertmessage: "First Name not found")
                return
            }
            
            guard let lastName = user["last_name"] as? String else
            {
                self.showAlert(alertmessage: "Last Name not found")
                return
            }
            
            udacityUser.firstName = firstName
            udacityUser.lastName = lastName
            let name = "\(firstName) \(lastName)"
            udacityUser.userName = name
            
            //Get location information of all student in the network
            udClient.getStudentLocations(completionHandlerForLocations: { (sucess,locationError) in
                if sucess == true
                {
                    //User Data and Student Location has been fetched. Display the Next Screen
                    self.displayTabView()
                }
                else
                {
                    self.showAlert(alertmessage: "Unable to fetch student locations")
                    print(locationError)
                }
                
            })
            
            
        })

    }
    
    func displayTabView() {
        //Transition to Table View Screen
        performUIUpdatesOnMain {
            let tabViewController = self.storyboard!.instantiateViewController(withIdentifier: "TabView") as! UITabBarController
            self.present(tabViewController, animated: true, completion: nil)
        }
    }

}





