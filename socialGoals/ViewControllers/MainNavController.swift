//
//  MainNavController.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-09.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit
import Firebase

class MainNavController: UINavigationController {
    
    let loadingSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.style = .gray
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
/****************************************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingSpinner.startAnimating()
        view.addSubview(loadingSpinner)
        loadingSpinner.center = view.center
        
        view.backgroundColor = .white
        navigationBar.isHidden = true
        
        if isLoggedIn() {
            
            // if isLoggedIn, we can assume Auth currentUser is not nil.
            let uid = Auth.auth().currentUser!.uid
            
            isUsernameSet(uid: uid) { (usernameSet) in
                self.viewControllers = [LoginController()]
                
                if usernameSet {
                    self.present(HomeController(), animated: true, completion: nil)
                } else {
                    self.viewControllers.append(HomeController())
                    self.pushViewController(OnboardingBase(), animated: false)
                }
                
                self.loadingSpinner.stopAnimating()
                
            }
            
        } else {
            pushViewController(LoginController(), animated: true)
            loadingSpinner.stopAnimating()
        }
        
    }
    
/****************************************************************************************/
    
    private func isLoggedIn() -> Bool {
        
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
        
    }
    
}
