//
//  DiscoverTab.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-12.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit
import Firebase

// get lists that are not mine AND are Public
class DiscoverTab: UIViewController {
    
    let cellId = "cellId"

    var lists: [MyListCellData] = [] {
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
        layout.minimumLineSpacing = 50
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = false
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceVertical = true
        
        cv.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        
        return cv
    }()
    
    let refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        return refresh
    }()
    
    @objc func handleRefresh() {
        
        if let uid = getUid() {
            getDiscoverLists(uid: uid) { (listsList) in
                self.updateLists(listsList: listsList)
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
        navigationItem.title = "Discover"
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = Colors.brandTurquoiseBlue
        edgesForExtendedLayout = []
        
        loadingSpinner.startAnimating()
        
        if let uid = getUid() {
            getDiscoverLists(uid: uid) { (listsList) in
                self.updateLists(listsList: listsList)
                self.loadingSpinner.stopAnimating()
            }
        }
        
        registerCells()
        setupViews()
    }
    
    /****************************************************************************************/
    
    func registerCells() {
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func setupViews() {
        
        view.addSubview(collectionView)
        collectionView.addSubview(refreshControl)
        
        collectionView.anchorToTop(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.center = view.center
    }
    
    // assign newLists to lists while profile imgs are loading. Once each loads, create a new MyListCellData with the img and replace the existing MyListCellData in lists at the same index.
    func updateLists(listsList: [Dictionary<String, Any>]) {
        
        var newLists: [MyListCellData] = []
        
        for list in listsList {
            guard let goalDescs = list["goals"] as? [String] else { continue }
            guard let goalCompletions = list["goalCompletions"] as? [Bool] else { continue }
            
            var goals: [(Bool, String)] = []
            for index in 0...goalDescs.count-1 {
                let newGoal = (goalCompletions[index], goalDescs[index])
                goals.append(newGoal)
            }
            
            let nowDate = Date()
            let dateCreated = list["dateCreated"] as? Timestamp ?? Timestamp(date: nowDate)
            let lastUpdated = list["lastUpdated"] as? Timestamp ?? Timestamp(date: nowDate)
            let localNow = list["localLastUpdated"] as? String ?? localDateFormatter.string(from: nowDate)
            
            guard let username = list["username"] as? String else { continue }
            guard let uid = list["uid"] as? String else { return }
            
            let categoryString = list["categoryString"] as? String ?? "daily"
            guard let privacyString = list["privacyString"] as? String else { continue }
            
            let privacy = stringToListPrivacy(privacyString: privacyString)
            let category = stringToListCategory(categoryString: categoryString)
            
            let docId = list["docId"] as! String
            
            let numberOfComments = list["numberOfComments"] as? Int ?? 0
            
            let profileImgUrl = list["profileImgUrl"] as? String
            let currentList = MyListCellData(dateCreated: dateCreated, lastUpdatedServer: lastUpdated, lastUpdatedLocal: localNow, username: username, uid: uid, privacy: privacy, profileImgString: profileImgUrl, category: category, goals: goals, docId: docId, numberOfComments: numberOfComments)
            newLists.append(currentList)

        }
        
        lists = newLists
        
    }
    
}

extension DiscoverTab: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListCell
        
        cell.delegate = self
        cell.data = lists[indexPath.row]
        
        return cell
    }
    
}

extension DiscoverTab: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 500)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

extension DiscoverTab: ListCellDelegate {
    
    func showProfileVC(username: String, isMyProfile: Bool) {
        let profileVC = ProfileVC()
        
        profileVC.username = username
        profileVC.isMyProfile = isMyProfile
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func showCommentsVC(uid: String, docId: String, categoryString: String) {
        let commentsVC = CommentsVC()
        
        let listData: Dictionary<String, String> = [
            "uid": uid,
            "docId": docId,
            "categoryString": categoryString
        ]
        commentsVC.listData = listData
        
        navigationController?.pushViewController(commentsVC, animated: true)
    }
    
}
