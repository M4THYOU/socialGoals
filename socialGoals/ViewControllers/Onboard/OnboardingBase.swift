//
//  OnboardNavController.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-09.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit
import FirebaseAuth
import Mixpanel

class OnboardingBase: UIViewController {
    
    let usernameCellId = "usernameCellId"
    let inviteFriendsCellId = "inviteFriendsCellId"
    
    let numberOfPages = 2
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        
        return cv
    }()
    
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        
        pc.pageIndicatorTintColor = UIColor.lightGray
        pc.currentPageIndicatorTintColor = Colors.brandBabyBlue
        
        return pc
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Next", for: .normal)
        button.setTitleColor(Colors.brandBabyBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        button.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        
        return button
    }()
    
    @objc func nextPage() {
        
        //last screen
        if pageControl.currentPage == numberOfPages - 1 {
            navigationController?.popViewController(animated: true)
            Mixpanel.mainInstance().track(event: "onboard_complete")
            return
        }
        
        // if not username screen
        if pageControl.currentPage != 0 {
            return
        }
        
        Mixpanel.mainInstance().track(event: "onboard_username_set")
        checkUsername()
        
    }
    
    /****************************************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.numberOfPages = numberOfPages
        
        view.backgroundColor = .white
        
        registerCells()
        setupViews()
        
    }
    
    /****************************************************************************************/
    
    func setupViews() {
        
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        
        view.addSubview(nextButton)
        
        collectionView.anchorToTop(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        _ = pageControl.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 60)
        
        _ = nextButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 30, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 50)
        
    }
    
    func registerCells() {
        collectionView.register(UsernameCell.self, forCellWithReuseIdentifier: usernameCellId)
        collectionView.register(InviteFriendsCell.self, forCellWithReuseIdentifier: inviteFriendsCellId)
    }
    
    func checkUsername() {
        
        guard let currentCell = collectionView.visibleCells[0] as? UsernameCell else { return }
        
        let username = currentCell.usernameTextField.text ?? ""
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedUsername.matches("^[a-zA-Z0-9._-]{3,30}$") {
            currentCell.errorLabel.text = "Must be 3-30 characters. Only numbers, letters, periods, underscores, and dashes."
            currentCell.usernameTextField.layer.borderColor = Colors.warningRed.cgColor
            return
        }
        
        checkIfUsernameExists(username: trimmedUsername) { (exists) in
            
            if exists {
                currentCell.errorLabel.text = "Username already taken."
                currentCell.usernameTextField.layer.borderColor = Colors.warningRed.cgColor
                
            } else {
                self.usernameNotExistsHandler(username: trimmedUsername, currentCell: currentCell)
            }
            
        }
        
    }
    
    func usernameNotExistsHandler(username: String, currentCell: UsernameCell) {
        
        let uid = getUid()
        if uid == nil {
            currentCell.errorLabel.text = "Not logged in. Please restart the app."
            currentCell.usernameTextField.layer.borderColor = Colors.warningRed.cgColor
            return
        }
        
        setUserUsername(uid: uid!, username: username)
        
        currentCell.errorLabel.text = nil
        currentCell.usernameTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        let indexPath = IndexPath(item: pageControl.currentPage + 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageControl.currentPage += 1
        
    }
    
}

extension OnboardingBase: UICollectionViewDelegate {}

extension OnboardingBase: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let usernameCell = collectionView.dequeueReusableCell(withReuseIdentifier: usernameCellId, for: indexPath) as! UsernameCell
            
            return usernameCell
        } else {
            let inviteFriendsCell = collectionView.dequeueReusableCell(withReuseIdentifier: inviteFriendsCellId, for: indexPath) as! InviteFriendsCell
            nextButton.setTitle("Done", for: .normal)
            inviteFriendsCell.delegate = self
            
            return inviteFriendsCell
        }
    }
    
}

extension OnboardingBase: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
}

extension OnboardingBase: InviteFriendsCellDelegate {
    
    func showShareDialog() {
        
        let textToShare = "Let's achieve our goals together with socialGoals!"
        let appLink = "https://apps.apple.com/app/socialgoals/idxxxxxxxx"
        
        guard let appUrl = URL(string: appLink) else { return }
        
        let objectsToShare = [textToShare, appUrl] as [Any]
        
        let shareVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        shareVC.popoverPresentationController?.sourceView = self.collectionView
        present(shareVC, animated: true, completion: nil)
        
    }
    
}
