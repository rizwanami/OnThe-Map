//
//  LinkViewController.swift
//  OnTheMap
//
//  Created by Mohammed Ibrahim on 11/5/16.
//  Copyright © 2016 myw. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LinkViewController : UIViewController,MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var textField: UITextField!
    
    @IBOutlet var mapView: MKMapView!
    
    
    @IBOutlet var submit: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var coordinate : CLLocationCoordinate2D!
    var annotations : [MKAnnotation] = []
    let udacityClient = UdacityClient()
    
    override func viewDidLoad() {
        self.loadMap()
        self.mapView.delegate = self
        mapView.isHidden = false
        
    }
    func loadMap() {
        let coordinate = CLLocationCoordinate2D(latitude:locationEntred.latitude! , longitude: locationEntred.longitude!)
        
        self.coordinate = coordinate
        let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        mapView.setRegion(region, animated: true)
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.mapAnnptation()
        self.activityIndicator.isHidden = true
        
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        locationEntred.locationEntred = textField.text
        textField.resignFirstResponder()
        return true
    }
    
    func mapAnnptation() {
        let annotation = MKPointAnnotation()
        annotation.title = udacityUser.userName
        annotation.coordinate = self.coordinate
        annotation.subtitle = textField.text
        self.annotations.append(annotation)
        self.mapView.addAnnotations(self.annotations)
    }
    
    func updateTheList(comletionHandlerForUpdateTheList : @escaping (_ success : Bool)-> Void) {
        self.UIEnable(status: false)
        mapAnnptation()
        let HttpBody = "{\"uniqueKey\": \"\(udacityUser.userID)\", \"firstName\": \"\(udacityUser.firstName)\", \"lastName\": \"\(udacityUser.lastName)\",\"mapString\": \"\(locationEntred.locationEntred!)\", \"mediaURL\": \"\(locationEntred.urlEntred!)\",\"latitude\":\(locationEntred.latitude!), \"longitude\":\(locationEntred.longitude!)}"
        if udacityUser.objectId == "" {
            self.udacityClient.postParseApi(method: udMethods.postStudentLocations, httpBody: HttpBody, range: 0){ (data, error) in
                guard error == "" else {
                    if error == "The operation couldn’t be completed. (kCLErrorDomain error 2.)" {
                        print(error)
                        self.showAlert(alerttitle: "Cannot Connect To Server", alertmessage: "Please Check Your Internet Connection")
                        self.submit.isEnabled = true
                        self.activityIndicator.isHidden = true
                    }
                    else
                    {
                        self.showAlert(alerttitle: "Unknown Error", alertmessage: "Error : \(error)")
                        print(error)
                    }
                    return
                }
                guard let data = data as? NSDictionary else {
                    print("There is no data found")
                    return
                }
                
                guard let objectId = data["objectId"] as? String else  {
                    print("Unable to find ObjectId")
                    return
                    
                }
                
                udacityUser.objectId = objectId
                
                self.udacityClient.getStudentLocations(completionHandlerForLocations:{ (success, error) in
                    if success == true {
                        performUIUpdatesOnMain() {
                            self.UIEnable(status: true)
                            comletionHandlerForUpdateTheList(true)
                        }
                    }
                    else
                        if error == "The operation couldn’t be completed. (kCLErrorDomain error 2.)"
                        {
                            print(error)
                            self.showAlert(alerttitle: "Cannot Connect To Server", alertmessage: "Please Check Your Internet Connection")
                            self.submit.isEnabled = true
                            self.activityIndicator.isHidden = true
                    }
                })
            }
        }
        else
        {
            self.udacityClient.putParseApi(method: udMethods.updateStudentLocations, httpBody: HttpBody, range: 0) { (data, error) in
                guard error == nil || error == "" else {
                    if error == "The operation couldn’t be completed. (kCLErrorDomain error 2.)" {
                        print(error)
                        self.showAlert(alerttitle: "Cannot Connect To Server", alertmessage: "Please Check Your Internet Connection")
                        self.submit.isEnabled = true
                        self.activityIndicator.isHidden = true
                    }
                    else {
                        print(error)
                    }
                    return
                }
                guard let data = data as? NSDictionary else {
                    print("NO data is found")
                    return
                }
                print(data)
                self.udacityClient.getStudentLocations(completionHandlerForLocations: {(success, error) in
                    if success == true {
                        performUIUpdatesOnMain() {
                            self.UIEnable(status: true)
                            comletionHandlerForUpdateTheList(true)
                        }
                    }
                    else if error == "The operation couldn’t be completed. (kCLErrorDomain error 2.)"{
                        print(error)
                        self.showAlert(alerttitle: "Cannot Connect To Server", alertmessage: "Please Check Your Internet Connection")
                        self.submit.isEnabled = true
                        self.activityIndicator.isHidden = true
                    }
                })
            }
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reUseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reUseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reUseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .infoLight)
            
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    func mapView(_ mapView : MKMapView,  annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            let myURLString =  (view.annotation?.subtitle)!
            
            if let myURL = URL(string: myURLString!) {
                if app.canOpenURL(myURL) {
                    app.openURL(myURL)
                }
            }
            
        }
    }
    
    
    @IBAction func submit(_ sender: AnyObject) {
        
        locationEntred.urlEntred = textField.text
        activityIndicator.startAnimating()
        
        self.UIEnable(status: false)
        performUIUpdatesOnMain() {
            if self.textField.text == "" {
                self.UIEnable(status: true)
                self.showAlert(alerttitle: "URL field is empty"
                    , alertmessage: "Please enter the location url")
                
            }
                
            else {
                
                self.updateTheList(comletionHandlerForUpdateTheList: { (success: Bool) in
                    if success == true {
                        self.performSegue(withIdentifier: "tabBarViewController", sender: self)
                    } else {
                        self.showAlert(alerttitle: "Cannot Connect To Server", alertmessage: "Please Check Your Internet Connection")
                        self.submit.isEnabled = true
                        self.activityIndicator.isHidden = true
                    }
                })
            }
            
        }
    }
    
    @IBAction func Cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func UIEnable(status : Bool) {
        self.submit.isEnabled = status
        self.textField.isEnabled = status
        self.activityIndicator.isHidden = status
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
