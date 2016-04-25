//
//  SignInVC.swift
//  FishSticks
//
//  Created by Miwand Najafe on 2016-04-25.
//  Copyright © 2016 Miwand Najafe. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {
    
    @IBOutlet weak var shipNameField:UITextField!
    @IBOutlet weak var emailField:UITextField!
    @IBOutlet weak var passField:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    @IBAction func attemptLogin(sender:UIButton) {
        if let shipName = shipNameField.text where shipName != "",
            let email = emailField.text where email != "",
            let pass = passField.text where pass != "" {
            
            DataService.instance.REF_BASE.authUser(email, password: pass, withCompletionBlock: { (error, authData) in
                if error != nil {
                    if error.code == STATUS_ACCOUNT_NONEXIST {
                        DataService.instance.REF_BASE.createUser(email, password: pass, withValueCompletionBlock: { (error, result) in
                            if error != nil {
                                self.handleError("Could not create account", message: "Problem creating account. Try something else")
                            } else {
                                
                                

                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                DataService.instance.REF_BASE.authUser(email, password: pass, withCompletionBlock: { (err, data) in
                                    let user =
                                    [
                                        "Ship Name": shipName,
                                        "userEmail": email
                                    ]
                                    DataService.instance.createFirebaseUser(data.uid, user: user)
                                    
                                })
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: self)
                            }
                        })
                    } else {
                        self.handleError("Could not login", message: "Please check your username or pass")
                    }
                }
                else {
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: self)
                }
            })
        } else {
            handleError("Error missing values", message: "Fill out all values")
        }
    }
    
    func handleError(title:String,message:String) {
        let alertControl = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertControl.addAction(okAction)
        self.presentViewController(alertControl, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SEGUE_LOGGED_IN {
            let navVC = segue.destinationViewController as! UINavigationController
            let destinationVC = navVC.topViewController as! FishingInfoVC
            destinationVC.shipName = shipNameField.text
        }
    }
}