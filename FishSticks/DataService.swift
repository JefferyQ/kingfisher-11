//
//  DataService.swift
//  FishSticks
//
//  Created by Miwand Najafe on 2016-04-25.
//  Copyright © 2016 Miwand Najafe. All rights reserved.
//

import Firebase

class DataService {
    static let instance = DataService()
    
    private var _REF_BASE = Firebase(url: URL_FB_BASE)
    
    
    
    private var _REF_USERS = Firebase(url:"\(URL_FB_BASE)/users")
    private var _REF_POSTS = Firebase(url: "\(URL_FB_BASE)/posts")
    
    var REF_BASE:Firebase {
        return _REF_BASE
    }
    var REF_POSTS: Firebase {
        return _REF_POSTS
    }
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    func createFirebaseUser(uid:String, user: Dictionary<String,String>) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
 
}