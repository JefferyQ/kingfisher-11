//
//  ViewController.swift
//  FishSticks
//
//  Created by Miwand Najafe on 2016-04-23.
//  Copyright © 2016 Miwand Najafe. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imgPicker = UIImagePickerController()
    @IBOutlet weak var imgSelected:UIImageView!
    @IBOutlet weak var getImageBtn:UIButton!
    @IBOutlet weak var speciesField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var lengthField: UITextField!
    @IBOutlet weak var sexField: UITextField!
    @IBOutlet weak var breadthField: UITextField!
    
    var fishDelegate:FishProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgPicker.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        if imgSelected.image != nil {
            getImageBtn.setTitle("", forState: .Normal)
        } else {
            getImageBtn.setTitle("Pick an Image", forState: .Normal)
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imgSelected.image = image
        
        if let imgToSearch = imgSelected.image,
            imageData = UIImagePNGRepresentation(imgToSearch)
        {
            let imgData = imageData.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
            
            getData(imgData)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func getImage(sender:UIButton) {
        imgPicker.allowsEditing = true
        imgPicker.sourceType = .PhotoLibrary
        presentViewController(imgPicker, animated: true, completion: nil)
        
    }
    
    func getData(imageData:String) {
        APIClient.instance.getData(imageData) { (data) in
            if let response = data["responses"] as? [NSDictionary] {
                if let labelAnnot = response[0]["labelAnnotations"] as? NSArray {
                    var descriptions = [(String,Double)]()
                    for label in labelAnnot {
                        if let l = label as? NSDictionary {
                            if let desc = l["description"] as? String,
                                confidence = l["score"] as? Double {
                                let value = (desc,confidence)
                                descriptions.append(value)
                            }
                        }
                    }
                    self.readData(descriptions)
                }
            }
        }
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        
        if let breadth = breadthField.text,
            sex = sexField.text,
            weight = weightField.text,
            species = speciesField.text,
            length = lengthField.text,
            _ = imgSelected.image {
            
            
           let fish = FishModel(species: species, length: length, weight: weight, breadth: breadth, sex: sex)
            fishDelegate?.getFishData(fish)
            
            self.breadthField.text = ""
            self.sexField.text = ""
            self.weightField.text = ""
            self.speciesField.text = ""
            self.lengthField.text = ""
            self.imgSelected.image = nil
        } else {
            let alertControl = UIAlertController(title: "Missing values", message: "Please enter all values", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alertControl.addAction(okAction)
            self.presentViewController(alertControl, animated: true, completion: nil)
        }
    }
    
    func readData(descriptions:[(String,Double)]) {
        if let path = NSBundle.mainBundle().pathForResource("FishNames", ofType: "rtf"){
            
            do {
                let data = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                let myStrings = data.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                var values = [(String,Double)]()
                for fishData in descriptions {
                    if myStrings.contains(fishData.0.capitalizedString + "\\") {
                        values.append(fishData.0,fishData.1)
                    }
                }
                let finalValues = values.sort({$0.1 > $1.1}).first
                dispatch_async(dispatch_get_main_queue(), {
                    if finalValues != nil {
                    self.speciesField.text = finalValues!.0
                    } else {
                        let alertControl = UIAlertController(title: "Could not find a match", message: "Sorry no match found", preferredStyle: .Alert)
                        let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                        alertControl.addAction(okAction)
                        self.presentViewController(alertControl, animated: true, completion: nil)
                    }
                })
                
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
    }
}

