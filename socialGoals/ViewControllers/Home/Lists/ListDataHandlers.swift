//
//  ListDataHandlers.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-12.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit
import Firebase

enum ListPrivacy {
    case myself
    case circle
    case public_
}

enum ListCategory {
    case daily
    case weekly
    //case monthly
    //case yearly
    //case career
    //case financial
    //case personaldev
    //case relationship
    //case health
}

struct MyListCellData {
    let dateCreated: Timestamp // for reads, not used when writing. Just set to Timestamp(date: Date()).
    let lastUpdatedServer: Timestamp // for reads, not used when writing. Just set to Timestamp(date: Date()).
    let lastUpdatedLocal: String // for use identifying when to reset daily lists.
    let username: String
    let uid: String
    let privacy: ListPrivacy
    let profileImgString: String?
    let category: ListCategory
    let goals: [(Bool, String)] // [(IsComplete, GoalDesc), (IsComplete, GoalDesc)]
    let docId: String? // for reads, not used when writing. Just set to nil
    let numberOfComments: Int
}

func listCategoryToColor(category: ListCategory) -> UIColor {
    var color: UIColor?
    
    switch category {
    case ListCategory.daily:
        color = Colors.brandTurquoiseBlue
    case ListCategory.weekly:
        color = Colors.brandBabyBlue
    /*
    case ListCategory.monthly:
        color = Colors.textDarkBlue
    case ListCategory.yearly:
        color = Colors.brandYellow
    case ListCategory.career:
        color = .brown
    case ListCategory.financial:
        color = .green
    case ListCategory.personaldev:
        color = .orange
    case ListCategory.relationship:
        color = .purple // want pink
    case ListCategory.health:
        color = .red*/
    }
    
    return color!
    
}

func listCategoryToString(category: ListCategory) -> String {
    var categoryString: String = "Category not set"
    
    switch category {
    case ListCategory.daily:
        categoryString = "Daily"
    case ListCategory.weekly:
        categoryString = "Weekly"
        /*
    case ListCategory.monthly:
        categoryString = "Monthly"
    case ListCategory.yearly:
        categoryString = "Yearly"
    case ListCategory.career:
        categoryString = "Career"///Education
    case ListCategory.financial:
        categoryString = "Financial"
    case ListCategory.personaldev:
        categoryString = "Personal Development"
    case ListCategory.relationship:
        categoryString = "Relationship"
    case ListCategory.health:
        categoryString = "Health"///Fitness*/
    }
    
    return categoryString
    
}

func stringToListCategory(categoryString: String) -> ListCategory {
    let categoryString = categoryString.lowercased()
    var category: ListCategory = .daily
    
    switch categoryString {
    case "daily":
        category = .daily
    case "weekly":
        category = .weekly
        /*
    case "monthly":
        category = .monthly
    case "yearly":
        category = .yearly
    case "career":
        category = .career
    case "financial":
        category = .financial
    case "personal development":
        category = .personaldev
    case "relationship":
        category = .relationship
    case "health":
        category = .health*/
    default:
        category = .daily
    }
    
    return category
    
}

func listPrivacyToString(privacy: ListPrivacy) -> String {
    var privacyString: String = "Privacy not set"
    
    switch privacy {
    case ListPrivacy.public_:
        privacyString = "Public"
    case ListPrivacy.circle:
        privacyString = "Circle"
    case ListPrivacy.myself:
        privacyString = "Myself"
    }
    
    return privacyString
    
}

func stringToListPrivacy(privacyString: String) -> ListPrivacy {
    let privacyString = privacyString.lowercased()
    
    var privacy: ListPrivacy = .myself
    switch privacyString {
    case "public":
        privacy = .public_
    case "circle":
        privacy = .circle
    case "myself":
        privacy = .myself
    default:
        privacy = .myself
    }
    
    return privacy
    
}
