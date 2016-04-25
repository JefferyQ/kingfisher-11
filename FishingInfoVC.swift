//
//  FishingInfoVC.swift
//  FishSticks
//
//  Created by Miwand Najafe on 2016-04-24.
//  Copyright © 2016 Miwand Najafe. All rights reserved.
//

import UIKit
import MessageUI
import Firebase
import CoreLocation

protocol FishProtocol {
    func  getFishData(fish:FishModel)
}

class FishingInfoVC: UIViewController, FishProtocol, MFMailComposeViewControllerDelegate  {
    
    var shipName:String!
    var messageBody:String = ""
    var postForFB: NSDictionary?
    @IBOutlet weak var shipNameLbl: UILabel!
    @IBOutlet weak var emailField:MaterialTextField!
    @IBOutlet weak var gearField:MaterialTextField!
    @IBOutlet weak var biggestCatchLbl:UILabel!
    @IBOutlet weak var biggestCatchLengthLbl:UILabel!
    @IBOutlet weak var fishCaught: UILabel!
    
    var fishes = [FishModel]()
    var currentLocation = CLLocation()
    let locManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveData()
        shipNameLbl.text = shipName
        loadData()
        
        
        
        locManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways) {
            
            currentLocation = locManager.location!
            
        }
    }
    
    func saveData() {
        if NSUserDefaults.standardUserDefaults().valueForKey("shipName") != nil {
            shipName = NSUserDefaults.standardUserDefaults().valueForKey("shipName") as? String
        } else {
            NSUserDefaults.standardUserDefaults().setValue(shipName, forKey: "shipName")
        }
    }
    
    func loadData() {
        if NSUserDefaults.standardUserDefaults().valueForKey("gear") != nil {
            gearField.text = NSUserDefaults.standardUserDefaults().valueForKey("gear") as? String
        }
        if NSUserDefaults.standardUserDefaults().valueForKey("biggestCatch") != nil {
            biggestCatchLengthLbl.text = NSUserDefaults.standardUserDefaults().valueForKey("biggestLength") as? String
            biggestCatchLbl.text = NSUserDefaults.standardUserDefaults().valueForKey("biggestCatch") as? String
        }
    }
    
    func savePersonalData() {

            NSUserDefaults.standardUserDefaults().setValue(gearField.text, forKey: "gear")
            NSUserDefaults.standardUserDefaults().setValue(biggestCatchLengthLbl.text, forKey: "biggestLength")
            NSUserDefaults.standardUserDefaults().setValue(biggestCatchLbl.text, forKey: "biggestCatch")
    }
    
    override func viewWillAppear(animated: Bool) {
        formatData()
        
    }
    
    func  getFishData(fish:FishModel) {
        fishes.append(fish)
    }
    
    func formatData() {
        if fishes.count > 0 {
            var fishData = [String]()
            
            for data in fishes {
                let currentFish: [String:AnyObject] =
                    [
                        "Fish_Species":data.species,
                        "Fish_Length":data.length,
                        "Fish_Breadth":data.breadth,
                        "Fish_Weight":data.weight,
                        "Fish_sex":data.sex
                ]
                fishData.append(currentFish.description)
            }
            
            let date = NSDate()
            let params: [String:AnyObject] =
                [
                    "Ship_Name": shipName,
                    "Gear": gearField.text!,
                    "Email": emailField.text!,
                    "Time": date.description,
                    "Location": ["latitude": currentLocation.coordinate.latitude,
                        "longitude": currentLocation.coordinate.longitude],
                    "FishData": fishData
            ]
            messageBody = params.debugDescription
            postForFB = params
            print(params)
            dispatch_async(dispatch_get_main_queue(), {
                self.updateUI()
            })
        }
    }
    
    func updateUI() {
        var fishSpecies = ""
        
        for fish in fishes {
            let f = fish.species
            fishSpecies += f
            fishSpecies += " , "
        }
        let max = fishes.map({$0.length}).sort(>).first!
        let fishData = fishes.filter({$0.length == max})
        
        let newFishFormatData = fishData[0].length.stringByReplacingOccurrencesOfString(" cm", withString: "")
        if NSUserDefaults.standardUserDefaults().valueForKey("biggestLength") != nil {
            let biggestFishLength = NSUserDefaults.standardUserDefaults().valueForKey("biggestLength") as? String
            let biggestFish = NSUserDefaults.standardUserDefaults().valueForKey("biggestCatch") as? String
            let oldFormatFishLength = biggestFishLength?.stringByReplacingOccurrencesOfString(" cm", withString: "")
            if Float(newFishFormatData) > Float(oldFormatFishLength!) {
                biggestCatchLbl.text = fishData[0].species
                biggestCatchLengthLbl.text = fishData[0].length
            } else {
                biggestCatchLengthLbl.text = biggestFishLength
                biggestCatchLbl.text = biggestFish
                
            }
        } else {
        biggestCatchLbl.text = fishData[0].species
        biggestCatchLengthLbl.text = fishData[0].length
            
        }
        savePersonalData()
        self.fishCaught.text = fishSpecies
    }
    
    @IBAction func submitData(sender:UIButton) {
        if messageBody != "" && emailField.text != "" && gearField.text != "" {
            savePersonalData()
            postToFireBase()
            let mailComposeViewController = configureMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showEmailErrorAlert("Could not send email",message:"Your device could not send the e-mail. Please check the email and try again" )
            }
        } else {
            let alertControl = UIAlertController(title: "Nothing to submit", message: "Please enter all values before submitting", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alertControl.addAction(okAction)
            self.presentViewController(alertControl, animated: true, completion: nil)
        }
    }
    @IBAction func addFish(sender: AnyObject) {
            self.performSegueWithIdentifier("addFish", sender: self)
    }
    
    func configureMailComposeViewController() -> MFMailComposeViewController {
        let mailComponentVC = MFMailComposeViewController()
        mailComponentVC.mailComposeDelegate = self
        let recipients = self.emailField.text?.componentsSeparatedByString(",")
        mailComponentVC.setToRecipients(recipients)
        mailComponentVC.setSubject("Fishing data")
        mailComponentVC.setMessageBody(messageBody, isHTML: false)
        return mailComponentVC
    }
    
    func showEmailErrorAlert(title:String,message:String) {
        let alertControl = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertControl.addAction(okAction)
        self.presentViewController(alertControl, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Cancelled")
        case MFMailComposeResultSent.rawValue:
            self.showEmailErrorAlert("Success", message: "Message was sent")
        case MFMailComposeResultFailed.rawValue:
            self.showEmailErrorAlert("Failed", message: "Message was not sent. Try again later.")
        default:
            break
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postToFireBase () {
        let firebasePost = DataService.instance.REF_POSTS.childByAutoId()
        firebasePost.setValue(postForFB)
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addFish" {
            let destinationVC = segue.destinationViewController as! ViewController
            destinationVC.fishDelegate = self
        }
    }
}
