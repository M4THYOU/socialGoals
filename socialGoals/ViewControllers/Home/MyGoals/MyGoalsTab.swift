//
//  MyGoalsTab.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-12.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit
import Firebase
import Mixpanel

class MyGoalsTab: UIViewController {
    
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
        Mixpanel.mainInstance().track(event: "MyGoalsTab_refresh")
        
        if let uid = getUid() {
            getUserLists(uid: uid) { (listsList) in
                self.updateLists(listsList: listsList)
                self.refreshControl.endRefreshing()
            }
        } else {
            refreshControl.endRefreshing()
        }
        
    }
    
    @objc func handleAddNewList() {
        Mixpanel.mainInstance().track(event: "MyGoalsTab_new_list_builder_opened")
        
        let addNewGoalVC = AddNewGoal()
        addNewGoalVC.completeDelegate = self
        navigationController?.pushViewController(addNewGoalVC, animated: true)
    }
    
    /****************************************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = "My Goals"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddNewList))
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = Colors.brandTurquoiseBlue
        edgesForExtendedLayout = []
        
        loadingSpinner.startAnimating()
        
        if let uid = getUid() {
            getUserLists(uid: uid) { (listsList) in
                self.updateLists(listsList: listsList)
                self.loadingSpinner.stopAnimating()
            }
        }
        
        registerCells()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Mixpanel.mainInstance().track(event: "MyGoalsTab_opened")
    }
    
    /****************************************************************************************/
    
    func registerCells() {
        collectionView.register(MyListCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func setupViews() {
        
        view.addSubview(collectionView)
        collectionView.addSubview(refreshControl)
        
        collectionView.anchorToTop(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.center = view.center
        
    }
    
    func updateLists(listsList: [Dictionary<String, Any>]) {
        
        var profileImgUrl: String? = nil
        if let user = udGetUser() {
            profileImgUrl = user.profileImgUrl
        }
        
        lists = createNewLists(listsList: listsList, profileImg: nil, profileImgString: profileImgUrl)
        
    }
    
    func createNewLists(listsList: [Dictionary<String, Any>], profileImg: UIImage?, profileImgString: String?) -> [MyListCellData] {
        
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
            guard let uid = list["uid"] as? String else { continue }
            
            let categoryString = list["categoryString"] as? String ?? "daily"
            guard let privacyString = list["privacyString"] as? String else { continue }
            
            let privacy = stringToListPrivacy(privacyString: privacyString)
            let category = stringToListCategory(categoryString: categoryString)
            
            let docId = list["docId"] as! String
            
            let numberOfComments = list["numberOfComments"] as? Int ?? 0
            
            let currentList = MyListCellData(dateCreated: dateCreated, lastUpdatedServer: lastUpdated, lastUpdatedLocal: localNow, username: username, uid: uid, privacy: privacy, profileImgString: profileImgString, category: category, goals: goals, docId: docId, numberOfComments: numberOfComments)
            newLists.append(currentList)
        }
        
        return newLists
        
    }
    
}

extension MyGoalsTab: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myListCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MyListCell
        
        myListCell.delegate = self
        myListCell.data = lists[indexPath.row]
        
        return myListCell
    }
    
}

extension MyGoalsTab: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 500)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

extension MyGoalsTab: MyListCellDelegate {
    
    func showPrivacyActionSheet(sender: UIButton, currentCell: MyListCell) {
        Mixpanel.mainInstance().track(event: "MyGoalsTab_privacy_action_sheet_shown")
        
        let alert = UIAlertController(title: "Select who can see this list.", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Public", style: .default, handler: { (action) in
            Mixpanel.mainInstance().track(event: "MyGoalsTab_list_privacy_changed", properties: ["newPrivacy": "Public"])
            
            let newPrivacy = ListPrivacy.public_
            let privacyTitle = listPrivacyToString(privacy: newPrivacy)
            sender.setTitle(privacyTitle, for: .normal)
            
            guard let currentCellData = currentCell.data else { return }
            guard let currentDocId = currentCellData.docId else { return }
            let categoryString = listCategoryToString(category: currentCellData.category)
            guard let uid = getUid() else { return }
            
            updateListPrivacy(uid: uid, docId: currentDocId, categoryString: categoryString, newPrivacy: newPrivacy)
        }))
        
        alert.addAction(UIAlertAction(title: "Circle", style: .default, handler: { (action) in
            Mixpanel.mainInstance().track(event: "MyGoalsTab_list_privacy_changed", properties: ["newPrivacy": "Circle"])
            
            let newPrivacy = ListPrivacy.circle
            let privacyTitle = listPrivacyToString(privacy: newPrivacy)
            sender.setTitle(privacyTitle, for: .normal)
            
            guard let currentCellData = currentCell.data else { return }
            guard let currentDocId = currentCellData.docId else { return }
            let categoryString = listCategoryToString(category: currentCellData.category)
            guard let uid = getUid() else { return }
            
            updateListPrivacy(uid: uid, docId: currentDocId, categoryString: categoryString, newPrivacy: newPrivacy)
        }))
        
        alert.addAction(UIAlertAction(title: "Myself", style: .default, handler: { (action) in
            Mixpanel.mainInstance().track(event: "MyGoalsTab_list_privacy_changed", properties: ["newPrivacy": "Myself"])
            
            let newPrivacy = ListPrivacy.myself
            let privacyTitle = listPrivacyToString(privacy: newPrivacy)
            sender.setTitle(privacyTitle, for: .normal)
            
            guard let currentCellData = currentCell.data else { return }
            guard let currentDocId = currentCellData.docId else { return }
            let categoryString = listCategoryToString(category: currentCellData.category)
            guard let uid = getUid() else { return }
            
            updateListPrivacy(uid: uid, docId: currentDocId, categoryString: categoryString, newPrivacy: newPrivacy)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func showMoreActionSheet(currentCell: MyListCell) {
        Mixpanel.mainInstance().track(event: "MyGoalsTab_more_action_sheet_shown")
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            Mixpanel.mainInstance().track(event: "MyGoalsTab_list_deleted")
            
            if let removedIndex = self.collectionView.indexPath(for: currentCell)?.row {
                self.lists.remove(at: removedIndex)
            }
            guard let currentCellData = currentCell.data else { return }
            guard let currentDocId = currentCellData.docId else { return }
            
            let categoryString = listCategoryToString(category: currentCellData.category)
            
            guard let uid = getUid() else { return }
            
            deleteList(uid: uid, docId: currentDocId, categoryString: categoryString)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func showProfileVC(username: String, isMyProfile: Bool) {
        Mixpanel.mainInstance().track(event: "MyGoalsTab_profileVC_opened")
        
        let profileVC = ProfileVC()
        
        profileVC.username = username
        profileVC.isMyProfile = isMyProfile
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func showCommentsVC(uid: String, docId: String, categoryString: String) {
        Mixpanel.mainInstance().track(event: "MyGoalsTab_commentsVC_opened")
        
        let commentsVC = CommentsVC()
        
        let listData: Dictionary<String, String> = [
            "uid": uid,
            "docId": docId,
            "categoryString": categoryString
        ]
        commentsVC.listData = listData
        
        navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    func showShareDialog(username: String) {
        Mixpanel.mainInstance().track(event: "MyGoalsTab_completed_list")
        
        let alert = UIAlertController(title: "Well Done!", message: "Let your friends and family know how much you've accomplished and invite them to socialGoals.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Later", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { (_) in
            Mixpanel.mainInstance().track(event: "MyGoalsTab_share_complete_list")
            
            let textToShare = "I've just completed another list of goals on socialGoals! Come join me, my username is \(username)"
            let appLink = "https://socialgoals-22f09.web.app"
            
            guard let appUrl = URL(string: appLink) else { return }
            
            let objectsToShare = [textToShare, appUrl] as [Any]
            
            let shareVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            shareVC.popoverPresentationController?.sourceView = self.collectionView
            self.present(shareVC, animated: true, completion: nil)
            
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
}

extension MyGoalsTab: AddNewGoalCompleteDelegate {
    
    func addListToLists(list: MyListCellData) {
        Mixpanel.mainInstance().track(event: "MyGoalsTab_new_list_added")
        lists.append(list)
    }
    
}
