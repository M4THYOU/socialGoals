//
//  MyCircleTab.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-12.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit
import Mixpanel

class MyCircleTab: UIViewController {
    
    let cellId = "cellId"
    
    var circleUsers: [MyCircleCellData] = [] {
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
        layout.minimumInteritemSpacing = 0
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
        Mixpanel.mainInstance().track(event: "MyCircleTab_refresh")
        
        if let uid = getUid() {
            getCircleUsers(uid: uid) { (userList) in
                self.updateCircleUsers(userList: userList)
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
        navigationItem.title = "My Circle"
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = Colors.brandTurquoiseBlue
        edgesForExtendedLayout = []
        
        loadingSpinner.startAnimating()
        
        if let uid = getUid() {
            getCircleUsers(uid: uid) { (userList) in
                self.updateCircleUsers(userList: userList)
                self.loadingSpinner.stopAnimating()
            }
        }
        
        registerCells()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Mixpanel.mainInstance().track(event: "MyCircleTab_opened")
    }
    
    /****************************************************************************************/
    
    func registerCells() {
        collectionView.register(MyCircleCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func setupViews() {
        
        view.addSubview(collectionView)
        collectionView.addSubview(refreshControl)
        
        collectionView.anchorToTop(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.center = view.center
        
    }
    
    func updateCircleUsers(userList: [Dictionary<String, Any>]) {
        
        var currentCircleUsers: [MyCircleCellData] = []
        
        for user in userList {
            
            guard let profileImgUrl = user["profileImgUrl"] as? String else { continue }
            guard let username = user["username"] as? String else { continue }
            
            let currentCircleUser = MyCircleCellData(username: username, profileImgString: profileImgUrl)
            currentCircleUsers.append(currentCircleUser)
            
        }
        
        circleUsers = currentCircleUsers
        
    }
    
}

extension MyCircleTab: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return circleUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MyCircleCell
        
        cell.data = circleUsers[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Mixpanel.mainInstance().track(event: "MyCircleTab_profileVC_opened")
        let circleUser = circleUsers[indexPath.row]
            
        let profileVC = ProfileVC()
        profileVC.username = circleUser.username
        profileVC.isMyProfile = false
            
        navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
}

extension MyCircleTab: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (view.frame.width / 2)
        
        return CGSize(width: width, height: 120)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}
