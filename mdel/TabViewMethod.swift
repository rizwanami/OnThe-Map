//
//  TabViewMethod.swift
//  OnTheMap
//
//  Created by Mohammed Ibrahim on 11/2/16.
//  Copyright © 2016 myw. All rights reserved.
//

import Foundation
import MapKit
class TabViewMethod : UIViewController {
    func pinTapped(_ sender: AnyObject) {
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
    
    
}
