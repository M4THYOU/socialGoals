//
//  NewListTableView.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-14.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

protocol NewListTableViewGoalDelegateA {
    func getGoalA() -> String? // not a list. This delegate gets called individually on each cell.
}
protocol NewListTableViewGoalDelegateB {
    func getGoalB() -> String? // not a list. This delegate gets called individually on each cell.
}
protocol NewListTableViewGoalDelegateC {
    func getGoalC() -> String? // not a list. This delegate gets called individually on each cell.
}

protocol NewListTableViewCategoryDelegate {
    func getCategory() -> ListCategory
}

protocol NewListTableViewPrivacyDelegate {
    func getPrivacy() -> ListPrivacy
}

class NewListTableView: UITableView {
    
    var goalDelegateA: NewListTableViewGoalDelegateA?
    var goalDelegateB: NewListTableViewGoalDelegateB?
    var goalDelegateC: NewListTableViewGoalDelegateC?
    var categoryDelegate: NewListTableViewCategoryDelegate?
    var privacyDelegate: NewListTableViewPrivacyDelegate?
    
    let goalFieldCellId = "goalFieldCellId"
    let categoryFieldCellId = "categoryFieldCellId"
    let privacyFieldCellId = "privacyFieldCellId"
    
    var sectionsTitles: [String]
    var sectionRows: [[NewListCellData]]
    
    /******************************/
    
    init(sectionTitles: [String], sectionRows: [[NewListCellData]]) {
        
        self.sectionsTitles = sectionTitles
        self.sectionRows = sectionRows
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
        
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /******************************/
    
    func setupViews() {
        
        dataSource = self
        
        registerCells()
        
    }
    
    func registerCells() {
        self.register(GoalFieldCell.self, forCellReuseIdentifier: goalFieldCellId)
        self.register(CategoryFieldCell.self, forCellReuseIdentifier: categoryFieldCellId)
        self.register(PrivacyFieldCell.self, forCellReuseIdentifier: privacyFieldCellId)
    }
    
}

extension NewListTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionRows[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: goalFieldCellId, for: indexPath) as! GoalFieldCell
            if indexPath.row == 0 {
                goalDelegateA = cell
            } else if indexPath.row == 1 {
                goalDelegateB = cell
            } else {
                goalDelegateC = cell
            }
            
            cell.data = sectionRows[indexPath.section][indexPath.row]
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: categoryFieldCellId, for: indexPath) as! CategoryFieldCell
            categoryDelegate = cell
            
            cell.data = sectionRows[indexPath.section][indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: privacyFieldCellId, for: indexPath) as! PrivacyFieldCell
            privacyDelegate = cell
            
            cell.data = sectionRows[indexPath.section][indexPath.row]
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsTitles[section]
    }
    
}

extension NewListTableView: AddNewGoalDelegate {
    
    func getListData() -> Dictionary<String, Any> {
        var goalA: String = ""
        var goalB: String = ""
        var goalC: String = ""
        var category: ListCategory = .daily
        var privacy: ListPrivacy = .public_
        
        if let goalDelA = goalDelegateA {
            goalA = goalDelA.getGoalA() ?? ""
            goalA = goalA.replacingOccurrences(of: "\t", with: "")
            goalA = goalA.replacingOccurrences(of: "\n", with: "")
            goalA = goalA.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let goalDelB = goalDelegateB {
            goalB = goalDelB.getGoalB() ?? ""
            goalB = goalB.replacingOccurrences(of: "\t", with: "")
            goalB = goalB.replacingOccurrences(of: "\n", with: "")
            goalB = goalB.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let goalDelC = goalDelegateC {
            goalC = goalDelC.getGoalC() ?? ""
            goalC = goalC.replacingOccurrences(of: "\t", with: "")
            goalC = goalC.replacingOccurrences(of: "\n", with: "")
            goalC = goalC.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if let categoryDelegate = categoryDelegate {
            category = categoryDelegate.getCategory()
        }
        
        if let privacyDelegate = privacyDelegate {
            privacy = privacyDelegate.getPrivacy()
        }
        
        let listDict: Dictionary<String, Any> = [
            "goalA": goalA,
            "goalB": goalB,
            "goalC": goalC,
            "category": category,
            "privacy": privacy
        ]
        
        return listDict
        
    }
    
}
