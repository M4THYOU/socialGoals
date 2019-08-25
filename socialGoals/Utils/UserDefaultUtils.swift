//
//  UserDefaultUtils.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-15.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

struct UserDefaultKeys {
    static let user = "user" // String
}

func udSetUser(user: User) {
    
    do {
        let encodedUser: Data = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
        UserDefaults.standard.set(encodedUser, forKey: UserDefaultKeys.user)
        UserDefaults.standard.synchronize()
    } catch {
        print("ERROR OCCURRED ADDING USER TO USERDEFAULT: \(error)")
    }
    //UserDefaults.standard.set(username, forKey: UserDefaultKeys.username)
    
}

func udGetUser() -> User? {
    
    guard let userData = UserDefaults.standard.data(forKey: UserDefaultKeys.user) else { return nil }
    
    do {
        let user = try NSKeyedUnarchiver.unarchivedObject(ofClass: User.self, from: userData)
        return user
    } catch {
        print("ERROR OCCURRED GETTING USER FROM USERDEFAULT: \(error)")
        return nil
    }
    
}
