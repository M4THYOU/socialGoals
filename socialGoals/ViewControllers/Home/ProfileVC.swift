//
//  Profile.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-20.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit
import Firebase
import Mixpanel

class ProfileVC: UIViewController {
    
    var inviteButtonStatus: InviteButtonStatus = .unknown
    
    let cellId = "cellId"
    
    var isMyProfile: Bool = false
    var username: String? {
        didSet {
            
            guard let username = username else { return }
            
            loadingSpinner.startAnimating()
            
            getUidFrom(username: username) { (uid) in
                guard let uid = uid else { return }
                self.profileUid = uid
                
                getUserDict(uid: uid, complete: { (userDict) in
                    guard let userDict = userDict else { return }
                    self.setupProfile(user: userDict)
                })
                
                getUserLists(uid: uid, complete: { (listsList) in
                    self.setupLists(viewedUserUid: uid, listsList: listsList)
                })
                
                if let myUid = getUid() {
                    
                    getCircleUser(currentUid: myUid, otherUid: uid, complete: { (user) in
                        if let user = user {
                            
                            guard let isInvite = user["isInvite"] as? Bool else { return }
                            
                            if isInvite {
                                //invite
                                self.setInviteButton(newInviteButtonStatus: .pending)
                            } else {
                                // in circle
                                self.setInviteButton(newInviteButtonStatus: .circle)
                            }
                            
                        } else {
                            // not in circle. (not invited yet either)
                            self.setInviteButton(newInviteButtonStatus: .none)
                        }
                    })
                }
                
            }
            
        }
    }
    var profileUid: String?
    var profileImgUrl: String?
    
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
        
        cv.backgroundColor = Colors.almostWhite
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
    
    /***/
    
    let profileImgView: UIImageView = {
        let image = #imageLiteral(resourceName: "default-profile-pic")
        let iv = UIImageView()
        
        iv.image = image
        iv.layer.borderWidth = 1
        iv.layer.masksToBounds = false
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.cornerRadius = 35 // (70 / 2)
        iv.clipsToBounds = true
        
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        
        label.text = "\t"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        
        return label
    }()
    
    let inviteButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Invite", for: .normal)
        button.setTitleColor(Colors.brandTurquoiseBlue, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        
        button.isEnabled = false
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        button.addTarget(self, action: #selector(handleInvite), for: .touchUpInside)
        
        return button
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Sign out", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        button.addTarget(self, action: #selector(handleSignout), for: .touchUpInside)
        
        return button
    }()
    
    /***/
    
    @objc func handleRefresh() {
        Mixpanel.mainInstance().track(event: "ProfileVC_refresh")
        
        guard let username = navigationItem.title else { return }
        
        getUidFrom(username: username) { (uid) in
            guard let uid = uid else { return }
            self.profileUid = uid
            
            getUserDict(uid: uid, complete: { (userDict) in
                guard let userDict = userDict else { return }
                self.setupProfile(user: userDict)
            })
            
            getUserLists(uid: uid, complete: { (listsList) in
                self.refreshControl.endRefreshing()
                self.setupLists(viewedUserUid: uid, listsList: listsList)
            })
            
            if let myUid = getUid() {
                
                getCircleUser(currentUid: myUid, otherUid: uid, complete: { (user) in
                    if let user = user {
                        
                        guard let isInvite = user["isInvite"] as? Bool else { return }
                        
                        if isInvite {
                            //invite
                            self.setInviteButton(newInviteButtonStatus: .pending)
                        } else {
                            // in circle
                            self.setInviteButton(newInviteButtonStatus: .circle)
                        }
                        
                    } else {
                        // not in circle. (not invited yet either)
                        self.setInviteButton(newInviteButtonStatus: .none)
                    }
                })
                
            }
            
        }
        
    }
    
    @objc func handleInvite() {
        Mixpanel.mainInstance().track(event: "ProfileVC_invite_button_pressed")
        
        switch inviteButtonStatus {
        case .none:
            // invite to circle
            setInviteButton(newInviteButtonStatus: .pending)
            
            if let currentUid = getUid() ?? udGetUser()?.uid {
                // get the current user and other user
                guard let currentUserDict = getCurentUserInviteDict(currentUid: currentUid) else { return }
                guard let otherUserDict = getOtherUserInviteDict() else { return }

                inviteToCircle(currentUser: currentUserDict, otherUser: otherUserDict)
            }
        
        case .circle:
            // remove from circle
            setInviteButton(newInviteButtonStatus: .none)
            
            fallthrough
            
        case .pending:
            // remove from circle
            setInviteButton(newInviteButtonStatus: .none)
            
            guard let currentUid = getUid() ?? udGetUser()?.uid else { return }
            guard let otherUid = profileUid else { return }
                
            removeFromCircle(currentUid: currentUid, otherUid: otherUid)
            
        case .unknown:
            // do nothing, button should be disabled anyway
            setInviteButton(newInviteButtonStatus: .unknown)
            
        }
        
    }
    
    @objc func handleSignout() {
        Mixpanel.mainInstance().track(event: "ProfileVC_signout")
        
        let alert = UIAlertController(title: "Sign out of socialGoals", message: "Are you sure you want to sign out of socialGoals?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: { (_) in
            signout()
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    /****************************************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = username
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = Colors.brandTurquoiseBlue
        edgesForExtendedLayout = []
        
        registerCells()
        
        if isMyProfile {
            setupMyProfileViews()
        } else {
            setupViews()
        }
    }
    
    /****************************************************************************************/
    
    func registerCells() {
        collectionView.register(ProfileListCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func setupMyProfileViews() {
        
        view.addSubview(profileImgView)
        view.addSubview(nameLabel)
        view.addSubview(logoutButton)
        
        view.addSubview(collectionView)
        collectionView.addSubview(refreshControl)
        
        _ = profileImgView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 70, heightConstant: 70)
        profileImgView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = nameLabel.anchor(top: profileImgView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = logoutButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: -15, widthConstant: 0, heightConstant: 0)
        
        _ = collectionView.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.center = view.center
    }
    
    func setupViews() {
        
        view.addSubview(profileImgView)
        view.addSubview(nameLabel)
        view.addSubview(inviteButton)
        
        view.addSubview(collectionView)
        collectionView.addSubview(refreshControl)
        
        _ = profileImgView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 70, heightConstant: 70)
        profileImgView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = nameLabel.anchor(top: profileImgView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = inviteButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: -15, widthConstant: 0, heightConstant: 0)
        
        _ = collectionView.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.center = view.center
    }
    
    func setupProfile(user: Dictionary<String, Any>) {
        
        let name = user["name"] as? String ?? ""
        
        if let profileImgString = user["profileImgUrl"] as? String {
            self.profileImgUrl = profileImgString
            let imgRef = getImgRef(imageUrl: profileImgString)
            let placeholder = #imageLiteral(resourceName: "default-profile-pic.jpg")
            profileImgView.sd_setImage(with: imgRef, placeholderImage: placeholder)
        }
        
        nameLabel.text = name
        
    }
    
    func setupLists(viewedUserUid: String, listsList: [Dictionary<String, Any>]) {
        
        if let currentUid = getUid() {
            
            if currentUid == viewedUserUid {
                var newLists: [MyListCellData] = []
                
                // maxprivaxy is the highest tier of privacy that can be seen.
                for list in listsList {
                    if let listData = listDictToCellData(listDict: list, maxPrivacy: .myself) {
                        newLists.append(listData)
                    }
                }
                
                lists = newLists
                loadingSpinner.stopAnimating()
                
            } else {
                // check if currentUser is circled with viewedUser. Display cirlce and/or public lists only.
                isInCircle(currentUid: currentUid, otherUid: viewedUserUid) { (inCircle) in
                    var newLists: [MyListCellData] = []
                    
                    for list in listsList {
                        if inCircle {
                            if let listData = self.listDictToCellData(listDict: list, maxPrivacy: .circle) {
                                newLists.append(listData)
                            }
                        } else {
                            if let listData = self.listDictToCellData(listDict: list, maxPrivacy: .public_) {
                                newLists.append(listData)
                            }
                        }
                    }
                    
                    self.lists = newLists
                    self.loadingSpinner.stopAnimating()
                    
                }
                
            }

        }
        
    }
    
    func listDictToCellData(listDict: Dictionary<String, Any>, maxPrivacy: ListPrivacy) -> MyListCellData? {
        
        guard let goalDescs = listDict["goals"] as? [String] else { return nil }
        guard let goalCompletions = listDict["goalCompletions"] as? [Bool] else { return nil }
        
        var goals: [(Bool, String)] = []
        for index in 0...goalDescs.count-1 {
            let newGoal = (goalCompletions[index], goalDescs[index])
            goals.append(newGoal)
        }
        
        let nowDate = Date()
        let dateCreated = listDict["dateCreated"] as? Timestamp ?? Timestamp(date: nowDate)
        let lastUpdated = listDict["lastUpdated"] as? Timestamp ?? Timestamp(date: nowDate)
        let localNow = listDict["localLastUpdated"] as? String ?? localDateFormatter.string(from: nowDate)
        
        guard let username = listDict["username"] as? String else { return nil }
        guard let uid = listDict["uid"] as? String else { return nil }
        
        let categoryString = listDict["categoryString"] as? String ?? "daily"
        guard let privacyString = listDict["privacyString"] as? String else { return nil }
        
        let privacy = stringToListPrivacy(privacyString: privacyString)
        let category = stringToListCategory(categoryString: categoryString)
        
        let docId = listDict["docId"] as! String
        
        let numberOfComments = listDict["numberOfComments"] as? Int ?? 0
        
        let currentList = MyListCellData(dateCreated: dateCreated, lastUpdatedServer: lastUpdated, lastUpdatedLocal: localNow, username: username, uid: uid, privacy: privacy, profileImgString: nil, category: category, goals: goals, docId: docId, numberOfComments: numberOfComments)
        
        // now filter based on maxPrivacy
        switch currentList.privacy {
        case .myself:
            if maxPrivacy == .myself {
                return currentList
            } else {
                return nil
            }
            
        case .circle:
            if maxPrivacy == .circle || maxPrivacy == .myself {
                return currentList
            } else {
                return nil
            }
            
        case .public_:
            // always return public lists
            return currentList
        }
        
    }
    
    func getCurentUserInviteDict(currentUid: String) -> Dictionary<String, String>? {
        
        guard let currentUser = udGetUser() else { return nil }
        guard let currentUsername = currentUser.username else { return nil }
        
        var currentUserDict: Dictionary<String, String> = [
            "uid": currentUid,
            "username": currentUsername,
        ]
        if let currentProfileImgUrl = currentUser.profileImgUrl {
            currentUserDict["profileImgUrl"] = currentProfileImgUrl
        }
        
        return currentUserDict
        
    }
    
    func getOtherUserInviteDict() -> Dictionary<String, String>? {
        
        guard let otherUid = profileUid else { return nil }
        guard let otherUsername = username else { return nil }
        
        var otherUserDict: Dictionary<String, String> = [
            "uid": otherUid,
            "username": otherUsername,
        ]
        if let otherProfileImgUrl = profileImgUrl {
            otherUserDict["profileImgUrl"] = otherProfileImgUrl
        }
        
        return otherUserDict
        
    }
    
    func setInviteButton(newInviteButtonStatus: InviteButtonStatus) {
        
        var title: String = "Invite"
        var isEnabled: Bool = false
        var borderColor: CGColor = UIColor.lightGray.cgColor
        
        switch newInviteButtonStatus {
        case .none:
            title = "Invite"
            isEnabled = true
            borderColor = Colors.brandTurquoiseBlue.cgColor
            
        case .circle:
            title = "In my circle"
            isEnabled = true
            borderColor = Colors.brandBabyBlue.cgColor
            
        case .pending:
            title = "Already Invited"
            isEnabled = true
            borderColor = Colors.brandBabyBlue.cgColor
            
        case .unknown:
            title = "Invite"
            isEnabled = false
            borderColor = UIColor.lightGray.cgColor
            
        }
        
        inviteButton.setTitle(title, for: .normal)
        inviteButton.isEnabled = isEnabled
        inviteButton.layer.borderColor = borderColor
        inviteButtonStatus = newInviteButtonStatus
        
    }
    
}

extension ProfileVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProfileListCell
        
        cell.delegate = self
        cell.data = lists[indexPath.row]
        
        return cell
    }
    
}

extension ProfileVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 400)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

extension ProfileVC: ProfileListCellDelegate {
    
    func showCommentsVC(uid: String, docId: String, categoryString: String) {
        Mixpanel.mainInstance().track(event: "ProfileVC_commentsVC_opened")
        
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
