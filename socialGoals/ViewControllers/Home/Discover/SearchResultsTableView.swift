//
//  SearchResultsTableView.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-26.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

class SearchResultsTableView: UITableView {
    
    let cellId = "cellId"
    var users: [SearchResultsCellData] = [] {
        didSet {
            reloadData()
        }
    }
    
    /******************************/
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .plain)
        
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
        register(SearchResultsCell.self, forCellReuseIdentifier: cellId)
    }
    
}

extension SearchResultsTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SearchResultsCell
        
        cell.data = users[indexPath.row]
        
        return cell
        
    }
    
}
