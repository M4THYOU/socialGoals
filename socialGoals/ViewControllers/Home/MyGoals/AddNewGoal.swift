//
//  AddNewGoal.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-14.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit
import Firebase

protocol AddNewGoalDelegate {
    func getListData() -> Dictionary<String, Any>
}

protocol AddNewGoalCompleteDelegate {
    func addListToLists(list: MyListCellData)
}

class AddNewGoal: UIViewController {
    
    var delegate: AddNewGoalDelegate?
    var completeDelegate: AddNewGoalCompleteDelegate?
    
    let loadingSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.style = .gray
        indicator.hidesWhenStopped = true
        
        return indicator
    }()
    
    let newGoalTableView: NewListTableView = {
        let goals = [
            NewListCellData(title: "1."),
            NewListCellData(title: "2."),
            NewListCellData(title: "3.")
        ]
        
        let category = [
            NewListCellData(title: "")
        ]
        
        let privacy = [
            NewListCellData(title: "About A")
        ]
        
        let sectionTitles = ["Goals", "Category", "Privacy"]
        let sectionRows = [goals, category, privacy]
        
        let table = NewListTableView(sectionTitles: sectionTitles, sectionRows: sectionRows)
        
        return table
    }()
    
    @objc func handleCancelButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleDoneButton() {
        guard let currentUser = udGetUser() else { return }
        guard let del = delegate else { return }
        
        let uid = currentUser.uid
        let username = currentUser.username ?? ""
        let profileImgUrl = currentUser.profileImgUrl
        
        let listData = del.getListData()
        
        let goalA = listData["goalA"] as? String ?? ""
        let goalB = listData["goalB"] as? String ?? ""
        let goalC = listData["goalC"] as? String ?? ""
    
        if goalA.isEmpty && goalB.isEmpty && goalC.isEmpty {
            print("NO GOALS ENTERED")
            return
        }
        
        var goals: [(Bool, String)] = []
        if !goalA.isEmpty {
            goals.append((false, goalA))
        }
        if !goalB.isEmpty {
            goals.append((false, goalB))
        }
        if !goalC.isEmpty {
            goals.append((false, goalC))
        }
        
        let category = listData["category"] as? ListCategory ?? ListCategory.daily
        let privacy = listData["privacy"] as? ListPrivacy ?? ListPrivacy.public_
        
        let nowDate = Date()
        let now = Timestamp(date: nowDate)
        let localNow = localDateFormatter.string(from: nowDate)
        
        let list = MyListCellData(dateCreated: now, lastUpdatedServer: now, lastUpdatedLocal: localNow, username: username, uid: uid, privacy: privacy, profileImgString: profileImgUrl, category: category, goals: goals, docId: nil, numberOfComments: 0)
        
        createNewList(uid: uid, list: list)
        addListToLists(list: list)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    /****************************************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.title = "Add New List"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDoneButton))
        navigationController?.navigationBar.barTintColor = .white
        
        delegate = newGoalTableView
        newGoalTableView.tableFooterView = UIView()
        
        setupViews()
    }
    
    /****************************************************************************************/
    
    func setupViews() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(loadingSpinner)
        loadingSpinner.center = view.center
        
        view.addSubview(newGoalTableView)
        
        _ = newGoalTableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
    }
    
    func addListToLists(list: MyListCellData) {
        if let del = completeDelegate {
            del.addListToLists(list: list)
        }
    }
    
}
