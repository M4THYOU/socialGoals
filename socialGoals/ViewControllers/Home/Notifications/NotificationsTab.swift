//
//  NotificationsTab.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-17.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

class NotificationsTab: UIViewController {
    
    let cellId = "cellId"
    
    var notifications: [NotificationCellData] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
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
        
        return cv
    }()
    
    let refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        return refresh
    }()
    
    @objc func handleRefresh() {
        
        if let uid = getUid() {
            getNotifications(uid: uid) { (notificationsList) in
                self.updateNotifications(notificationsList: notificationsList)
                self.refreshControl.endRefreshing()
            }
        } else {
            refreshControl.endRefreshing()
        }
        
    }
    
    /****************************************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = Colors.brandTurquoiseBlue
        edgesForExtendedLayout = []
        
        loadingSpinner.startAnimating()
        
        if let uid = getUid() {
            getNotifications(uid: uid) { (notificationsList) in
                self.updateNotifications(notificationsList: notificationsList)
                self.loadingSpinner.stopAnimating()
            }
        }
        
        registerCells()
        setupViews()
    }
    
    /****************************************************************************************/
    
    func registerCells() {
        collectionView.register(NotificationCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func setupViews() {
        
        view.addSubview(collectionView)
        collectionView.addSubview(refreshControl)
        
        collectionView.anchorToTop(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.center = view.center
        
    }
    
    func updateNotifications(notificationsList: [Dictionary<String, Any>]) {
        
        var newNotifications: [NotificationCellData] = []
        
        for list in notificationsList {
            print(list)
            guard let username = list["senderUsername"] as? String else { continue }
            
            let profileImgString = list["profileImgUrl"] as? String
            
            guard let notificationTypeString = list["type"] as? String else { continue }
            let notificationType = stringToNotificationType(notificationString: notificationTypeString)
            
            guard let isRead = list["isRead"] as? Bool else { continue }
            
            let listDocId = list["listDocId"] as? String
            
            var category: ListCategory?
            if let categoryString = list["category"] as? String {
                category = stringToListCategory(categoryString: categoryString)
            }
            
            let currentNotification = NotificationCellData(username: username, profileImgString: profileImgString, notificationType: notificationType, isRead: isRead, listDocId: listDocId, listCategory: category)
            
            newNotifications.append(currentNotification)
            
        }
        
        notifications = newNotifications
        
    }
    
}

extension NotificationsTab: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NotificationCell
        
        cell.delegate = self
        cell.data = notifications[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        if notification.notificationType == .comment {
            guard let docId = notification.listDocId else { return }
            guard let category = notification.listCategory else { return }
            let categoryString = listCategoryToString(category: category)
            
            let singleListVC = SingleListVC()
            singleListVC.docId = docId
            singleListVC.categoryString = categoryString
            singleListVC.fromNotifications = true
            
            navigationController?.pushViewController(singleListVC, animated: true)
            
        } else if notification.notificationType == .invite {
            
        }
        
    }
    
}

extension NotificationsTab: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        /*
        let width = view.frame.width
        let estimatedSize = CGSize(width: width, height: 150)
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        let estimatedFrame = NSString(string: comments[notifications.row].comment).boundingRect(with: estimatedSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        // 60px accounts for the profile image above the comment
        // 30px accounts for extra space needed
        let baseSize: CGFloat = 55
        let additionalMargin: CGFloat = 20
        return CGSize(width: width, height: estimatedFrame.size.height + baseSize + additionalMargin)*/
        return CGSize(width: view.frame.width, height: 80)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

extension NotificationsTab: NotificationCellDelegate {
    
    func showProfileVC(username: String, isMyProfile: Bool) {
        let profileVC = ProfileVC()
            
        profileVC.username = username
        profileVC.isMyProfile = isMyProfile
            
        navigationController?.pushViewController(profileVC, animated: true)
    }

}
