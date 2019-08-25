//
//  NotificationCellData.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-23.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

enum NotificationType {
    case comment
    case invite
}

struct NotificationCellData {
    let username: String
    let profileImgString: String?
    let notificationType: NotificationType
    let isRead: Bool
    let listDocId: String?
    let listCategory: ListCategory?
}

func notificationTypeToString(type: NotificationType) -> String {
    
    var notificationString: String = "Category not set"
    
    switch type {
    case .comment:
        notificationString = "comment"
    case .invite:
        notificationString = "invite"
    }
    
    return notificationString
    
}

func stringToNotificationType(notificationString: String) -> NotificationType {
    let notificationString = notificationString.lowercased()
    
    var type: NotificationType = .comment
    switch notificationString {
    case "comment":
        type = .comment
    case "invite":
        type = .invite
    default:
        type = .comment
    }
    
    return type
    
}
