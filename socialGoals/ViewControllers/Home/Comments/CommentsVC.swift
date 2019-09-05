//
//  CommentsVC.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-22.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit
import Firebase
import Mixpanel

class CommentsVC: UIViewController {
    
    let cellId = "cellId"
    
    var comments: [CommentCellData] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var listData: Dictionary<String, String>?
    
    let loadingSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.style = .gray
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = false
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceVertical = true
        
        cv.keyboardDismissMode = .onDrag
        
        return cv
    }()
    
    let commentTextField: CommentTextField = {
        let tf = CommentTextField()
        
        tf.layer.borderColor = UIColor.black.cgColor
        tf.layer.borderWidth = 1
        
        tf.placeholder = "Advice, Encouragement, Help..."
        tf.returnKeyType = .send
        
        return tf
    }()
    
    @objc func keyboardChange(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
                
                let keyboardHeight = keyboardFrame.height
                let navBarHeight = self.navigationController?.navigationBar.frame.height ?? 44.0
                let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 83.0
                
                let y = -(keyboardHeight) + navBarHeight + tabBarHeight
                
                self.view.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height)

                
            }, completion: nil)
            
        }
        
    }
    
    /****************************************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        view.backgroundColor = .white
        navigationItem.title = "Comments"
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = Colors.brandTurquoiseBlue
        edgesForExtendedLayout = []
        
        commentTextField.delegate = self
        
        loadingSpinner.startAnimating()
        
        if let listData = listData {
            if let docId = listData["docId"] {
                getListComments(docId: docId) { (commentsList) in
                    self.updateLists(commentsList: commentsList)
                    self.loadingSpinner.stopAnimating()
                }
            }
        }
        
        registerCells()
        setupViews()
    }
    
    /****************************************************************************************/
    
    func registerCells() {
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func setupViews() {
        
        view.addSubview(collectionView)
        view.addSubview(commentTextField)
        
        _ = commentTextField.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 3, bottomConstant: -3, rightConstant: -3, widthConstant: 0, heightConstant: 50)
        _ = collectionView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: commentTextField.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.center = view.center
    }
    
    func isValidComment() -> Bool {
        
        var commentText = commentTextField.text ?? ""
        commentText = commentText.replacingOccurrences(of: "\t", with: "")
        commentText = commentText.replacingOccurrences(of: "\n", with: "")
        commentText = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !commentText.isEmpty
        
    }
    
    func updateLists(commentsList: [Dictionary<String, Any>]) {
        
        var newComments: [CommentCellData] = []
        
        for list in commentsList {
            
            guard let dateCreated = list["timestamp"] as? Timestamp else { continue }
            guard let username = list["senderUsername"] as? String else { continue }
            let profileImgString = list["profileImgUrl"] as? String
            guard let comment = list["comment"] as? String else { continue }
            
            let currentComment = CommentCellData(dateCreated: dateCreated, username: username, profileImgString: profileImgString, comment: comment)
            
            newComments.append(currentComment)
            
        }
        
        comments = newComments
        
    }
    
}

extension CommentsVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        
        cell.delegate = self
        cell.data = comments[indexPath.row]
        
        return cell
    }
    
}

extension CommentsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        let estimatedSize = CGSize(width: width, height: 150)
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        let estimatedFrame = NSString(string: comments[indexPath.row].comment).boundingRect(with: estimatedSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        // 60px accounts for the profile image above the comment
        // 30px accounts for extra space needed
        let baseSize: CGFloat = 55
        let additionalMargin: CGFloat = 20
        return CGSize(width: width, height: estimatedFrame.size.height + baseSize + additionalMargin)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

extension CommentsVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let tfText = textField.text else { return false }
        guard let rangeToReplace = Range(range, in: tfText) else { return false }
        
        let substringToReplace = tfText[rangeToReplace]
        let count = tfText.count - substringToReplace.count + string.count
        
        return count <= 300
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        Mixpanel.mainInstance().track(event: "CommentsVC_send_button_pressed")
        
        if isValidComment() {
            if let currentUid = getUid() {
                
                guard let currentUser = udGetUser() else { return false }
                guard let currentUsername = currentUser.username else { return false }
                let profileImgUrl = currentUser.profileImgUrl
                let comment = commentTextField.text!
                
                guard let listData = listData else { return false }
                guard let docUid = listData["uid"] else { return false }
                guard let docId = listData["docId"] else { return false }
                guard let categoryString = listData["categoryString"] else { return false }
                
                //send it to db.
                addComment(currentUid: currentUid, currentUsername: currentUsername, profileImgUrl: profileImgUrl, comment: comment, docUid: docUid, docId: docId, categoryString: categoryString)
                
                //now post it on the screen
                let currentComment = CommentCellData(dateCreated: Timestamp(date: Date()), username: currentUsername, profileImgString: profileImgUrl, comment: comment)
                comments.append(currentComment)
                commentTextField.text = ""
                
            }
        }
        
        return false
        
    }
    
}

extension CommentsVC: CommentCellDelegate {
    
    func showProfileVC(username: String, isMyProfile: Bool) {
        Mixpanel.mainInstance().track(event: "CommentsVC_profileVC_opened")
        
        let profileVC = ProfileVC()
        
        profileVC.username = username
        profileVC.isMyProfile = isMyProfile
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
}
