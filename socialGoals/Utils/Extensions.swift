//
//  Extensions.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-10.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

extension UITableViewCell {
    
    var tableView: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }
            
            return table as? UITableView
        }
    }
    
}

extension UICollectionViewCell {
    
    var collectionView: UICollectionView? {
        get {
            var collection: UIView? = superview
            while !(collection is UICollectionView) && collection != nil {
                collection = collection?.superview
            }
            
            return collection as? UICollectionView
        }
    }
    
}
