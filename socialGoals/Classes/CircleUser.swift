//
//  CircleUser.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-15.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

class CircleUser {
    
    var username: String?
    var profileImgUrl: String?
    var uid: String
    
    init(dict: Dictionary<String, Any>) {
        
        username = dict["username"] as? String
        profileImgUrl = dict["profileImgUrl"] as? String
        uid = dict["uid"] as! String
        
    }
    
}
