//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Mohammed Ibrahim on 10/23/16.
//  Copyright © 2016 myw. All rights reserved.
//

import Foundation
import MapKit


class mapView: UIViewController,MKMapViewDelegate
{
    @IBOutlet weak var studentMap: MKMapView!
    @IBOutlet weak var Logout: UIBarButtonItem!
    @IBOutlet weak var pin: UIBarButtonItem!
    @IBOutlet weak var Refresh: UIBarButtonItem!
    
    var annotations = [MKPointAnnotation]()
    
    
    override func viewDidLoad()
    {
        
        self.loadAnnotation()
        self.studentMap.delegate = self
        
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView  = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoLight)
            
            
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            
            let mediaURLString = ((view.annotation?.subtitle)!)! as String
            if  let mediaURl = URL(string : mediaURLString) {
                if app.canOpenURL(mediaURl) {
                    app.openURL(mediaURl)
                } else {
                    showAlert(alerttitle:"Incomplete URL" , alertmessage:  "Media URL [\(mediaURLString)] is incorrect or not fully formed")
                }
            } else {
                showAlert(alerttitle: "Bad Media URL", alertmessage: "Media URL [\(mediaURLString)] is invalid")
            }
            
            
            
            
        }
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
                    self.UIEnable(status: true)
                    self.loadAnnotation()
                }
            } else if (error == "The Internet connection appears to be offline.") {
                
                //some message here
                performUIUpdatesOnMain{
                    self.showAlert(alerttitle: "Unable Connect To Server", alertmessage: "Check your internet connection")
                    
                }
            } else {
                //self.UIEnable(Status: true)
                print(error)
            }
        }
    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        let deletingCookies = UdacityClient()
        deletingCookies.logout(completionHandlerForLogOut:
            { (success, error) in
                if success == true {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showAlert(alerttitle: "Logout Error", alertmessage: "\(error)")
                    self.UIEnable(status: true)
                    print("logOut Error is: \(error)")
                }
        })
    }
    
    
    func loadAnnotation() {
        let locations = parseStudentLoc.studentLocations
        for Dictionary in locations! {
            if Dictionary["latitude"] != nil {
                
                let lat = CLLocationDegrees(Dictionary["latitude"] as! Double)
                let lon = CLLocationDegrees(Dictionary["longitude"] as! Double)
                let coordinate = CLLocationCoordinate2D(latitude : lat, longitude : lon)
                let first = Dictionary["firstName"] as! String
                if Dictionary["uniqueKey"]! as! String == udacityUser.userID {
                    
                    udacityUser.objectId = Dictionary["objectId"] as! String
                }
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                if let last = Dictionary["lastName"] as? String {
                    annotation.title = "\(first) \(last)"
                } else {
                    annotation.title = first
                }
                if let mediaurl = Dictionary["mediaURL"] as? String
                {
                    annotation.subtitle = mediaurl
                }
                annotations.append(annotation)
            }
        }
        self.studentMap.addAnnotations(annotations)
    }
    
    
    func showAlert(alerttitle: String, alertmessage: String) {
        let alertController = UIAlertController(title: alerttitle, message: alertmessage as String, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            action in alertController.dismiss(animated: true, completion: nil)
            
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func UIEnable(status : Bool) {
        Refresh.isEnabled = status
        Logout.isEnabled = status
        pin.isEnabled = status
        
    }
    
    
}


