//
//  APIClient.swift
//  FishSticks
//
//  Created by Miwand Najafe on 2016-04-24.
//  Copyright © 2016 Miwand Najafe. All rights reserved.
//

import Foundation
import UIKit

class APIClient {
    static let instance = APIClient()
    
    func getData(imageData:String,completion:(NSDictionary)-> ()) {
        
        guard let url = NSURL(string: URL_BASE + API_KEY) else {
            print("error with url")
            return
        }
        let request = NSMutableURLRequest (URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(NSBundle.mainBundle().bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        let jsonRequest: [String:AnyObject] = [
            "requests": [
                "image": [
                    "content": imageData
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonRequest, options: [])
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let session = NSURLSession.sharedSession()
            
            session.dataTaskWithRequest(request) { (data, response, error) in
                if let data = data {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                        completion(json)
                    } catch let err as NSError {
                        print(err.debugDescription)
                    }
                }
                }.resume()
        }
    }

    
    
}