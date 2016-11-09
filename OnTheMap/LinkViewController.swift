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
    var coordinate : CLLocationCoordinate2D!
    var annotations : [MKAnnotation] = []
    let udacityClient = UdacityClient()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        let coordinate = CLLocationCoordinate2D(latitude:locationEntred.latitude! , longitude: locationEntred.longitude!)
        
        self.coordinate = coordinate
        let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        mapView.setRegion(region, animated: true)
        mapAnnptation()
        

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
        let HttpBody = "{\"uniqueKey\": \"\(udacityUser.userID)\", \"firstName\": \"\(udacityUser.firstName)\", \"lastName\": \"\(udacityUser.lastName)\",\"mapString\": \"\(locationEntred.locationEntred)\", \"mediaURL\": \"\(locationEntred.urlEntred)\",\"latitude\":\(locationEntred.latitude), \"longitude\":\(locationEntred.longitude)}"
        if udacityUser.objectId == "" {
            self.udacityClient.postParseApi(method: udMethods.postStudentLocations, httpBody: HttpBody, range: 0){ (data, error) in
                guard error == nil else {
                    if error == "The Internet connection appears to be offline." {
                        performUIUpdatesOnMain() {
                            self.UIEnable(status: true)
                            let alert = UIAlertController()
                            alert.title = ""
                            alert.message = ""
                            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                                action in alert.dismiss(animated: true, completion: nil)
                            }
                            alert.addAction(alertAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                    else
                    {
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
                    {
                        print(error)
                    }
                })
                
            }
        }
        else
        {
            self.udacityClient.putParseApi(method: udMethods.updateStudentLocations, httpBody: HttpBody, range: 0) { (data, error) in
                guard error == nil else {
                    if error == "The Internet connection appears to be offline." {
                        performUIUpdatesOnMain() {
                            self.UIEnable(status: true)
                            let alert = UIAlertController()
                            alert.title = ""
                            alert.message = ""
                            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                                action in alert.dismiss(animated: true, completion: nil)
                                
                            }
                            alert.addAction(alertAction)
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        
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
                    else {
                        print(error)
                    }
                })
            }
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reUseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "reUseId") as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "reUseId")
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    func mapView(_ mapView : MKMapView,  annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle!              {
                app.canOpenURL((URL(string: toOpen))!)
                
            }
        }
        
    }
    
    @IBAction func submit(_ sender: AnyObject) {
        self.UIEnable(status: false)
        performUIUpdatesOnMain() {
        if self.textField.text == "" {
            self.UIEnable(status: true)
            let alert = UIAlertController()
            alert.title = "URL field is empty"
            alert.message = "Please enter the location url"
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                action in alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
            
            
            }
            
        }
                
    }
    func UIEnable(status : Bool) {
        self.submit.isEnabled = status
        self.textField.isEnabled = status
    }
    
}
