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


class studentLocationController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var submit: UIButton!
    var didGetLication : Bool = false
    override func viewDidLoad() {
        textField.delegate = self
}
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
        self.textField.resignFirstResponder()
        locationEntred.locationEntred = textField.text!
        return false
    }
    func getLocation(completionHandlerForGetLocation :@escaping (_ success : Bool)-> Void){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationEntred.locationEntred, completionHandler: {( placeMark : [CLPlacemark]?, error) in
            
            guard error == nil else {
                let error = ((error?.localizedDescription))
                print(error)
                if error == "The operation couldn’t be completed. (kCLErrorDomain error 2.)" {
                    print(error)
                    performUIUpdatesOnMain() {
                        self.submit.isEnabled = true
                        let alert = UIAlertController()
                        alert.title = "Cannot Connect To Server"
                        alert.message = "Please Check Your Internet Connection"
                        let alertAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default){
                        
                        action in alert.dismiss(animated: true, completion: nil)
                    }
                        alert.addAction(alertAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                    else if error == "The operation couldn’t be completed. (kCLErrorDomain error 8.)" {
                        performUIUpdatesOnMain() {
                            self.submit.isEnabled = true
                            let alert = UIAlertController()
                            alert.title = "Location Not Found"
                            alert.message = "Please try another Location"
                            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                                action in alert.dismiss(animated: true, completion: nil)
                                
                            }
                            alert.addAction(alertAction)

                        }
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
            locationEntred.latitude = latitude
            locationEntred.longitude = longitude
            completionHandlerForGetLocation(true)
            
        
        })
    
    
    }

}
