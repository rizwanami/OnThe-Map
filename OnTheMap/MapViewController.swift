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
        //Implement Annotation Load
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
            
            //pinView!.rightCalloutAccessoryView = UIButtonType.detailDisclosure as? UIView
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //mapView.addAnnotation(annotations as! MKAnnotation)
        
      if control == view.rightCalloutAccessoryView {
           let app = UIApplication.shared
        
        
        
//            if let toOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: (view.annotation?.subtitle!!)!)! as URL)
        //}
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
                self.performSegue(withIdentifier: "logOut", sender: self)
            } else {
                self.showAlert(alerttitle: "Logout Error", alertmessage: "\(error)")
                self.UIEnable(status: true)
                print("logOut Error is: \(error)")
            }
        })
    }
    
    //func uiEnable(Status : Bool) {
    //    pin.isEnabled = Status
    //    Logout.isEnabled = Status
    //    Refresh.isEnabled = Status
    //}
    
        //Load the Student Locations to the Map
    func loadAnnotation() {
        let locations = parseStudentLoc.studentLocations
        for Dictionary in locations! {
            if Dictionary["latitude"] != nil {
            
                let lat = CLLocationDegrees(Dictionary["latitude"] as! Double)
                let lon = CLLocationDegrees(Dictionary["longitude"] as! Double)
                let coordinate = CLLocationCoordinate2D(latitude : lat, longitude : lon)
                let first = Dictionary["firstName"] as! String
                let last = Dictionary["lastName"] as! String
                
                if Dictionary["uniqueKey"]! as! String == udacityUser.userID {
                    //self.showAlert(alerttitle: "User Found", alertmessage: Dictionary["lastName"] as! String)
                    udacityUser.objectId = Dictionary["objectId"] as! String
                }
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                if let mediaurl = Dictionary["mediaURL"] as? String
                {
                    annotation.subtitle = mediaurl
                }
                annotations.append(annotation)
            }
        }
        self.studentMap.addAnnotations(annotations)
    }
    
    //Display Alerts and Warning
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
    

