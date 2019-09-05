//
//  SearchResultsVC.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-26.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

protocol SearchResultsControllerDelegate {
    func showProfileVC(username: String, isMyProfile: Bool)
}

class SearchResultsController: UIViewController {
    
    var delegate: SearchResultsControllerDelegate?
    
    var listData: Dictionary<String, String>?
    
    let loadingSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.style = .gray
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    lazy var searchResultsTable: SearchResultsTableView = {
        let tv = SearchResultsTableView()
        
        tv.backgroundColor = .white
        tv.delegate = self
        tv.isPagingEnabled = false
        tv.showsHorizontalScrollIndicator = false
        tv.showsVerticalScrollIndicator = false
        tv.alwaysBounceVertical = true
        
        tv.keyboardDismissMode = .onDrag
        
        return tv
    }()
    
    /****************************************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = Colors.brandTurquoiseBlue
        edgesForExtendedLayout = []
        
        /*
        loadingSpinner.startAnimating()
        
        if let listData = listData {
            if let docId = listData["docId"] {
                getListComments(docId: docId) { (commentsList) in
                    self.updateLists(commentsList: commentsList)
                    self.loadingSpinner.stopAnimating()
                }
            }
        }*/
        
        setupViews()
    }
    
    /****************************************************************************************/
    
    func setupViews() {
        
        view.addSubview(searchResultsTable)
        
        searchResultsTable.anchorToTop(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.center = view.center
    }
    
    func updateUsers(usersList: [Dictionary<String, Any>]) {
        
        var newUsers: [SearchResultsCellData] = []
        
        for user in usersList {
            
            guard let username = user["username"] as? String else { continue }
            guard let uid = user["uid"] as? String else { return }
            let profileImgString = user["profileImgUrl"] as? String
            
            let currentUser = SearchResultsCellData(username: username, uid: uid, profileImgString: profileImgString)
            
            newUsers.append(currentUser)
            
        }
        
        searchResultsTable.users = newUsers
        
    }
    
    func showProfileVC(username: String, isMyProfile: Bool) {
        if let del = delegate {
            del.showProfileVC(username: username, isMyProfile: isMyProfile)
        }
    }
    
}

extension SearchResultsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedUser = searchResultsTable.users[indexPath.row]
        let username = selectedUser.username
        
        guard let currentUid = getUid() ?? udGetUser()?.uid else { return }
        let otherUid = selectedUser.uid
        
        let isMyProfile = currentUid == otherUid
        
        showProfileVC(username: username, isMyProfile: isMyProfile)
        
    }
    
}
