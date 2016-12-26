
//
//  studentLocationController.swift
//  OnTheMap
//
//  Created by Mohammed Ibrahim on 10/31/16.
//  Copyright © 2016 myw. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit


class studentLocationController : UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet var activityBar: UIActivityIndicatorView!
    @IBOutlet weak var submit: UIButton!
    var didGetLication : Bool = false
    
    
    override func viewDidLoad() {
        textField.delegate = self
        activityBar.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        activityBar.isHidden = true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    
    @IBAction func SubmitButton(_ sender: AnyObject) {
        
        
        self.submit.isEnabled = true
        locationEntred.locationEntred = textField.text
        
        if textField.text == "" {
            self.showAlert(alerttitle: "location textfield is empty", alertmessage: "Please enter Your location")
        }
        else {
            getLocation(completionHandlerForGetLocation: {(success) in
                if success == true {
                    
                    let controller : LinkViewController
                    controller = self.storyboard?.instantiateViewController(withIdentifier: "LinkViewController") as! LinkViewController
                    self.present(controller, animated: true, completion: nil)
                }
            })
            activityBar.isHidden = false
            activityBar.startAnimating()
        }
    }
    
    
    func getLocation(completionHandlerForGetLocation :@escaping (_ success : Bool)-> Void){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationEntred.locationEntred!, completionHandler: {( placeMark : [CLPlacemark]?, error) in
            
            guard error == nil else {
                let error = ((error?.localizedDescription))
                print(error)
                if error == "The operation couldn’t be completed. (kCLErrorDomain error 2.)" {
                    print(error)
                    self.showAlert(alerttitle: "Cannot Connect To Server", alertmessage: "Please Check Your Internet Connection")
                    self.submit.isEnabled = true
                    self.activityBar.isHidden = true
                }
                else if error == "The operation couldn’t be completed. (kCLErrorDomain error 8.)" {
                    self.showAlert(alerttitle: "Location Not Found", alertmessage: "Please try another Location")
                    self.activityBar.isHidden = true
                    self.submit.isEnabled = true
                }
                return
            }
            
            guard let placemark = placeMark else {
                print("NO Placemark ")
                return
                
            }
            guard let latitude = placemark[0].location?.coordinate.latitude else {
                print("could not coppy latitude")
                return
            }
            guard let longitude = placemark[0].location?.coordinate.longitude else {
                print("could not print longitude")
                return
            }
            self.activityBar.isHidden = false
            self.activityBar.startAnimating()
            locationEntred.latitude = latitude
            locationEntred.longitude = longitude
            completionHandlerForGetLocation(true)
        })
        
        
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
