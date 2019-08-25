//
//  User.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-15.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool {
        get {
            return true
        }
    }
    
    var username: String?
    var email: String
    var name: String
    var uid: String
    var profileImgUrl: String?
    var lists: [Dictionary<String, Any>]?
    var circle: [CircleUser]?
    
    init(username: String?, profileImgUrl: String?, email: String, name: String, uid: String) {
        self.username = username
        self.profileImgUrl = profileImgUrl
        
        self.email = email
        self.name = name
        self.uid = uid
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(username, forKey: "username")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(profileImgUrl, forKey: "profileImgUrl")
        aCoder.encode(lists, forKey: "lists")
        aCoder.encode(circle, forKey: "circle")
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        
        let currentUsername = aDecoder.decodeObject(forKey: "username") as? String
        let currentProfileImgUrl = aDecoder.decodeObject(forKey: "profileImgUrl") as? String
        
        let currentEmail = aDecoder.decodeObject(forKey: "email") as! String
        let currentName = aDecoder.decodeObject(forKey: "name") as! String
        let currentUid = aDecoder.decodeObject(forKey: "uid") as! String
        
        self.init(username: currentUsername, profileImgUrl: currentProfileImgUrl, email: currentEmail, name: currentName, uid: currentUid)
        
        //self.init(dict: userDict)
        
    }
    
}
