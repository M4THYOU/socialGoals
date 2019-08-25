//
//  auth.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-09.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

func getUid() -> String? {
    
    let currentUser = Auth.auth().currentUser
    let uid = currentUser?.uid
    
    return uid
    
}

func signInHandler(result: AuthDataResult?, error: Error?, navController: UINavigationController?, signIn: GIDSignIn?, data: Dictionary<String, String>) {
    
    if let error = error {
        print("Firebase authentication failed:", error)
        return
    }
    
    guard let result = result else { return }
    guard let isNewUser = result.additionalUserInfo?.isNewUser else { return }
    let uid = result.user.uid
    isUsernameSet(uid: uid) { (usernameSet) in
        
        if isNewUser || !usernameSet {
            
            if isNewUser {
                let email = data["email"]!
                let name = data["name"]!
                let imgUrlString = data["imgUrl"] ?? ""
                
                createNewUser(name: name, email: email, uid: uid)
                
                if let imgUrl = URL(string: imgUrlString) {
                    uploadProfileImg(uid: uid, imageUrl: imgUrl)
                } else {
                    print("Error parsing url from profile image string.")
                }
                
            }
            
            navController?.viewControllers.append(HomeController())
            if let signIn = signIn {
                GIDSignIn.sharedInstance()?.uiDelegate.sign?(signIn, present: OnboardingBase())
            } else {
                navController?.pushViewController(OnboardingBase(), animated: true)
            }
            
        } else {
            
            if let signIn = signIn {
                GIDSignIn.sharedInstance()?.uiDelegate.sign?(signIn, present: HomeController())
            } else {
                navController?.present(HomeController(), animated: true, completion: nil)
            }
        }
        
    }
    
}
