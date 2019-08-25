//
//  HomeController.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-09.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import FirebaseAuth
import GoogleSignIn

class HomeController: UITabBarController {
    
    let signOutButton: UIButton = {
        let button = UIButton(type: .system)
     
        button.backgroundColor = .purple
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.black, for: .normal)
     
        button.addTarget(self, action: #selector(handleSignOutButton), for: .touchUpInside)
     
        return button
    }()

    @objc func handleSignOutButton() {
    
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out")
            return
        }
        
        navigationController?.popViewController(animated: true)
        print("User logged out.")
     
     }
    
    /****************************************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        view.backgroundColor = .white
        
        setupViews()
        setupTabBar()
        
    }
    
    /****************************************************************************************/
    
    func setupViews() {
        
        //let screenWidth = UIScreen.main.bounds.width
        
        //view.addSubview(signOutButton)
        
        //_ = signOutButton.anchor(top: nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: screenWidth - 80, heightConstant: 40)
        //signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //signOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
    func setupTabBar() {
        
        let myGoalsTab = MyGoalsTab()
        
        let vcA = UINavigationController(rootViewController: myGoalsTab)
        vcA.tabBarItem.image = #imageLiteral(resourceName: "target-grey").withRenderingMode(.alwaysOriginal)
        vcA.tabBarItem.selectedImage = #imageLiteral(resourceName: "target-black").withRenderingMode(.alwaysOriginal)
        vcA.tabBarItem.imageInsets = UIEdgeInsets(top: 15, left: 0, bottom: -15, right: 0)
        
        let myCircleTab = MyCircleTab()
        let vcB = UINavigationController(rootViewController: myCircleTab)
        vcB.tabBarItem.image = #imageLiteral(resourceName: "circle-grey").withRenderingMode(.alwaysOriginal)
        vcB.tabBarItem.selectedImage = #imageLiteral(resourceName: "circle-black").withRenderingMode(.alwaysOriginal)
        vcB.tabBarItem.imageInsets = UIEdgeInsets(top: 15, left: 0, bottom: -15, right: 0)
        
        let discoverTab = DiscoverTab()
        let vcC = UINavigationController(rootViewController: discoverTab)
        vcC.tabBarItem.image = #imageLiteral(resourceName: "search-grey").withRenderingMode(.alwaysOriginal)
        vcC.tabBarItem.selectedImage = #imageLiteral(resourceName: "search-black").withRenderingMode(.alwaysOriginal)
        vcC.tabBarItem.imageInsets = UIEdgeInsets(top: 15, left: 0, bottom: -15, right: 0)
        
        let notificationsTab = NotificationsTab()
        let vcD = UINavigationController(rootViewController: notificationsTab)
        vcD.tabBarItem.image = #imageLiteral(resourceName: "notification-grey.png").withRenderingMode(.alwaysOriginal)
        vcD.tabBarItem.selectedImage = #imageLiteral(resourceName: "notification-black.png").withRenderingMode(.alwaysOriginal)
        vcD.tabBarItem.imageInsets = UIEdgeInsets(top: 15, left: 0, bottom: -15, right: 0)
        
        viewControllers = [vcA, vcB, vcC, vcD]
        
    }
    
}

extension HomeController: UITabBarControllerDelegate {
    
    /*
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        <#code#>
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        <#code#>
    }*/
    
}
