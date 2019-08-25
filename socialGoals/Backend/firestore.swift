//
//  firestore.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-09.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import Foundation
import Firebase

let db = Firestore.firestore()

func getUserDict(uid: String, complete: @escaping (Dictionary<String, Any>?) -> ()) {
    
    let userRef = db.collection("users").document(uid)
    
    userRef.getDocument { (doc, error) in
        if let error = error {
            print("Error getting user:", error)
        }
        
        complete(doc?.data())
        
    }
    
}

func getUidFrom(username: String, uid: @escaping (String?) -> ()) {
    
    let usernameRef = db.collection("usernames").document(username)
    
    usernameRef.getDocument { (doc, error) in
        if let error = error {
            print("Error getting user:", error)
            uid(nil)
        }
        
        guard let usernameDict = doc?.data() else { uid(nil); return }
        let currentUid = usernameDict["uid"] as? String
        
        uid(currentUid)
        
    }
    
}

func getUserToClass(uid: String, complete: @escaping (Bool) -> ()) {
    
    let userRef = db.collection("users").document(uid)
    
    userRef.getDocument { (doc, error) in
        
        if let _ = doc.flatMap({
            $0.data().flatMap({ (data) in
                
                let username = data["username"] as? String
                let profileImgUrl = data["profileImgUrl"] as? String
                
                let email = data["email"] as! String
                let name = data["name"] as! String
                let uid = data["uid"] as! String
                
                let user = User(username: username, profileImgUrl: profileImgUrl, email: email, name: name, uid: uid)
                udSetUser(user: user)
            })
        }) {
            complete(true)
        } else {
            print("Document does not exist")
            complete(false)
        }
        
    }
    
}

func isUsernameSet(uid: String, complete: @escaping (Bool) -> ()) {
    
    getUserDict(uid: uid) { (userDict) in
        
        if userDict == nil {
            complete(false)
        } else if userDict!["username"] == nil {
            complete(false)
        } else {
            complete(true)
        }
        
    }
    
}

func createNewUser(name: String, email: String, uid: String) {
    
    let now = Timestamp(date: Date()) // dateCreated and lastLogin
    
    let userData: [String: Any] = [
        "name": name,
        "email": email,
        "dateCreated": now,
        "lastLogin": now,
        "uid": uid
    ]
    
    db.collection("users").document(uid).setData(userData, merge: true) { (error) in
        if let error = error {
            print("Error adding user to db:", error)
        }
    }
    
}

func setUserProfilePictureURL(uid: String, url: String) {
    // listUsers and users
    let userData: [String: Any] = [
        "profileImgUrl": url
    ]
    
    db.collection("users").document(uid).setData(userData, merge: true) { (error) in
        if let error = error {
            print("Error updating user profile img url in db:", error)
        }
    }
    db.collection("listUsers").document(uid).setData(userData, merge: true) { (error) in
        if let error = error {
            print("Error updating list user profile img url in db:", error)
        }
    }
    
}

func checkIfUsernameExists(username: String, exists: @escaping (Bool) -> ()) {
    let usernameRef = db.collection("usernames").document(username)
    
    usernameRef.getDocument { (doc, error) in
        let docExists = doc?.exists ?? false
        exists(docExists)
    }
    
}

func setUserUsername(uid: String, username: String) {
    // listUsers, users, usernames (not allowed to change usernames YET)
    let userData: [String: Any] = [
        "username": username
    ]
    
    let userDataForUsernames: [String: Any] = [
        "uid": uid
    ]
    
    db.collection("users").document(uid).setData(userData, merge: true) { (error) in
        if let error = error {
            print("Error setting username in users collection:", error)
        }
    }
    db.collection("listUsers").document(uid).setData(userData, merge: true) { (error) in
        if let error = error {
            print("Error setting username in listUsers collection:", error)
        }
    }
    
    db.collection("usernames").document(username).setData(userDataForUsernames) { (error) in
        if let error = error {
            print("Error setting username in usernames collection:", error)
        }
    }
    
}

func createNewList(uid: String, list: MyListCellData) {
    
    let username = list.username
    let profileImgUrl = list.profileImgString
    
    let nowDate = Date()
    let dateCreated = Timestamp(date: nowDate)
    let lastUpdated = Timestamp(date: nowDate)
    let localNow = localDateFormatter.string(from: nowDate)
    let privacyString = listPrivacyToString(privacy: list.privacy)
    let categoryString = listCategoryToString(category: list.category)
    
    let goals = list.goals
    var parsedGoals: [String] = []
    var parsedGoalCompletions: [Bool] = []
    for goal in goals {
        parsedGoals.append(goal.1)
        parsedGoalCompletions.append(goal.0)
    }
    
    let numberOfComments = 0
    
    var listDict: Dictionary<String, Any> = [
        "username": username,
        "dateCreated": dateCreated,
        "lastUpdated": lastUpdated,
        "localLastUpdated": localNow,
        "privacyString": privacyString,
        "categoryString": categoryString,
        "goals": parsedGoals,
        "goalCompletions": parsedGoalCompletions,
        "uid": uid,
        "numberOfComments": numberOfComments
    ]
    
    if let profileImgUrl = profileImgUrl {
        listDict["profileImgUrl"] = profileImgUrl
    }
    
    // get the document id and use it for each write
    let listsRef = db.collection("lists").document()
    let docId = listsRef.documentID
    listDict["docId"] = docId
    
    // add to lists collection
    listsRef.setData(listDict) { (error) in
        if let error = error {
            print("Error adding new list to lists collection:", error)
        }
    }
    
    // add to respective category
    db.collection(categoryString).document(docId).setData(listDict) { (error) in
        if let error = error {
            print("Error adding new list to category collection:", error)
        }
    }
    
    // add to respective user
    db.collection("users").document(uid).collection("lists").document(docId).setData(listDict) { (error) in
        if let error = error {
            print("Error adding new list to user:", error)
        }
    }
    
    // add to respective user's respective category collection
    db.collection("users").document(uid).collection(categoryString).document(docId).setData(listDict) { (error) in
        if let error = error {
            print("Error adding new list to user's category:", error)
        }
    }
    
}

/**********/

func getUserLists(uid: String, complete: @escaping ([Dictionary<String, Any>]) -> ()) {
    
    let userRef = db.collection("users").document(uid)
    let userListsRef = userRef.collection("lists")
    let orderedUserListsRef = userListsRef.order(by: "lastUpdated", descending: true)
    
    orderedUserListsRef.getDocuments { (querySnapshot, error) in
        
        var lists: [Dictionary<String, Any>] = []
        if let error = error {
            print("Error getting user lists: \(error)")
        } else {
            for doc in querySnapshot!.documents {
                
                var docDict = doc.data()
                
                // checks if it is a new day. If so, reset the daily list.
                let shouldReset = checkDailyList(docDict: docDict, uid: uid)
                
                if shouldReset {
                    docDict["goalCompletions"] = [false, false, false]
                }
                
                lists.append(docDict)
            }
        }
        
        complete(lists)
        
    }
    
}

// get lists that are not mine AND are Public
func getDiscoverLists(uid: String, complete: @escaping ([Dictionary<String, Any>]) -> ()) {
    
    let listsRef = db.collection("lists")
    let random = listsRef.document()
    
    let randomLists = listsRef.whereField("__name__", isGreaterThanOrEqualTo: random)
        .whereField("privacyString", isEqualTo: "Public").limit(to: 3)
    randomLists.getDocuments { (querySnapshot, error) in
        
        var lists: [Dictionary<String, Any>] = []
        
        if let error = error {
            print("Error getting random lists: \(error)")
        } else {
            for doc in querySnapshot!.documents {
                var docDict = doc.data()
                guard let currentUid = docDict["uid"] as? String else { continue }
                if currentUid != uid {
                    
                    // checks if it is a new day. If so, reset the daily list.
                    let shouldReset = checkDailyList(docDict: docDict, uid: uid)
                    
                    if shouldReset {
                        docDict["goalCompletions"] = [false, false, false]
                    }
                    
                    lists.append(docDict)
                    
                }
            }
        }
        
        complete(lists)
        
    }
    
}

func checkDailyList(docDict: Dictionary<String, Any>, uid: String) -> Bool {
    
    // check if it is a daily list. If so, check lastUpdated. If NOT today, reset completions.
    guard let categoryString = docDict["categoryString"] as? String else { return false }
    let category = stringToListCategory(categoryString: categoryString)
    if category == ListCategory.daily {
        
        let nowDate = Date()
        
        let localLastUpdated = docDict["localLastUpdated"] as? String ?? localDateFormatter.string(from: nowDate)
        
        guard let localLastUpdatedDate = localDateFormatter.date(from: localLastUpdated) else { return false }
        let currentDateString = localDayDateFormatter.string(from: nowDate)
        guard let localStartOfDay = localDateFormatter.date(from: currentDateString + " 00:00:01") else { return false }
        
        if localLastUpdatedDate < localStartOfDay {
            // Last update of this daily list happened before today, therefore it is a new day. Reset it.
            guard let docId = docDict["docId"] as? String else { return true }
            guard let categoryString = docDict["categoryString"] as? String else { return true }
            resetCheckboxes(uid: uid, docId: docId, categoryString: categoryString)
            return true
        }
        
    }
    
    return false
    
}

/**********/

// from lists collection
func getList(docId: String, complete: @escaping (Dictionary<String, Any>?) -> ()) {
    
    let listRef = db.collection("lists").document(docId)
    
    listRef.getDocument { (doc, error) in
        if let error = error {
            print("Error getting list from lists collection: \(error)")
            complete(nil)
        }
        
        complete(doc?.data())
        
    }
    
}

func deleteList(uid: String, docId: String, categoryString: String) {
    
    // delete from lists collection
    db.collection("lists").document(docId).delete { (error) in
        if let error = error {
            print("Error deleting list from lists collection:", error)
        }
    }
    
    // delete from respective category
    db.collection(categoryString).document(docId).delete { (error) in
        if let error = error {
            print("Error deleting list from category collection:", error)
        }
    }
    
    // delete from respective user
    db.collection("users").document(uid).collection("lists").document(docId).delete { (error) in
        if let error = error {
            print("Error deleting list from user:", error)
        }
    }
    
    // delete from respective user's respective category collection
    db.collection("users").document(uid).collection(categoryString).document(docId).delete { (error) in
        if let error = error {
            print("Error deleting list from user's category:", error)
        }
    }
    
}

func updateListPrivacy(uid: String, docId: String, categoryString: String, newPrivacy: ListPrivacy) {
    
    
    let newPrivacyDict: Dictionary<String, Any> = [
        "privacyString": listPrivacyToString(privacy: newPrivacy)
    ]
    
    updateLists(uid: uid, docId: docId, categoryString: categoryString, updateDict: newPrivacyDict)
    
}

func updateCheckbox(uid: String, docId: String, categoryString: String, listIndex: Int, isChecked: Bool) {
    
    getList(docId: docId) { (list) in
        if let list = list {
            guard var goalCompletions = list["goalCompletions"] as? [Bool] else { return }
            goalCompletions[listIndex] = isChecked
            
            let newGoalCompletionsDict: Dictionary<String, Any> = [
                "goalCompletions": goalCompletions
            ]
            
            updateLists(uid: uid, docId: docId, categoryString: categoryString, updateDict: newGoalCompletionsDict)
        }
    }
    
}

func resetCheckboxes(uid: String, docId: String, categoryString: String) {
            
    let newGoalCompletionsDict: Dictionary<String, Any> = [
        "goalCompletions": [false, false, false]
    ]
            
    updateLists(uid: uid, docId: docId, categoryString: categoryString, updateDict: newGoalCompletionsDict)
    
}

func updateLists(uid: String, docId: String, categoryString: String, updateDict: Dictionary<String, Any>) {
    
    var newUpdateDict = updateDict
    let nowDate = Date()
    newUpdateDict["lastUpdated"] = Timestamp(date: nowDate)
    newUpdateDict["localLastUpdated"] = localDateFormatter.string(from: nowDate)
    
    // update lists collection
    db.collection("lists").document(docId).updateData(newUpdateDict) { (error) in
        if let error = error {
            print("Error updating privacy in lists collection:", error)
        }
    }
    
    // update respective category
    db.collection(categoryString).document(docId).updateData(newUpdateDict) { (error) in
        if let error = error {
            print("Error updating privacy in category collection:", error)
        }
    }
    
    // update respective user
    db.collection("users").document(uid).collection("lists").document(docId).updateData(newUpdateDict) { (error) in
        if let error = error {
            print("Error updating privacy in user:", error)
        }
    }
    
    // update respective user's respective category collection
    db.collection("users").document(uid).collection(categoryString).document(docId).updateData(newUpdateDict) { (error) in
        if let error = error {
            print("Error updating privacy in user's category:", error)
        }
    }
    
}

func addComment(currentUid: String, currentUsername: String, profileImgUrl: String?, comment: String, docUid: String, docId: String, categoryString: String) {
    
    let ts = Timestamp(date: Date())
    
    var newCommentDict: Dictionary<String, Any> = [
        "timestamp": ts,
        "senderUsername": currentUsername,
        "senderUid": currentUid,
        "comment": comment,
        "receiverUid": docUid,
        "listDocId": docId,
    ]
    if let profileImgUrl = profileImgUrl {
        newCommentDict["profileImgUrl"] = profileImgUrl
    }
    
    let listCommentsRef = db.collection("lists").document(docId).collection("comments").document()
    let commentDocId = listCommentsRef.documentID
    newCommentDict["docId"] = commentDocId
    
    //
    //
    //
    // add a comment to all 4 subcollections of comments for the current list.
    // add to lists collection
    db.collection("lists").document(docId).collection("comments").document(commentDocId).setData(newCommentDict) { (error) in
        if let error = error {
            print("Error adding comment to lists collection:", error)
        }
    }
    
    // add to respective category
    db.collection(categoryString).document(docId).collection("comments").document(commentDocId).setData(newCommentDict) { (error) in
        if let error = error {
            print("Error adding comment to category collection:", error)
        }
    }
    
    // add to respective user
    db.collection("users").document(docUid).collection("lists").document(docId).collection("comments").document(commentDocId).setData(newCommentDict) { (error) in
        if let error = error {
            print("Error adding comment to user:", error)
        }
    }
    
    // add to respective user's respective category collection
    db.collection("users").document(docUid).collection(categoryString).document(docId).collection("comments").document(commentDocId).setData(newCommentDict) { (error) in
        if let error = error {
            print("Error adding comment to user's category:", error)
        }
    }
    //
    //
    //
    
    //
    //
    //
    // add a comment notification to the docUid's (list owner's) notifications collection.
    // only do this if the user is not commenting on their own post.
    if !(docUid == currentUid) { // if the list's user is NOT the same as the comment user.
        
        var commentNotificationDict: Dictionary<String, Any> = [
            "timestamp": ts,
            "senderUsername": currentUsername,
            "senderUid": currentUid,
            "comment": comment,
            "receiverUid": docUid,
            "listDocId": docId,
            "type": notificationTypeToString(type: .comment),
            "isRead": false,
            "docId": commentDocId,
            "category": categoryString
        ]
        if let profileImgUrl = profileImgUrl {
            commentNotificationDict["profileImgUrl"] = profileImgUrl
        }
        
        db.collection("users").document(docUid).collection("notifications").document().setData(commentNotificationDict) { (error) in
            if let error = error {
                print("Error adding comment notification to user:", error)
            }
        }
    }
    //
    //
    //
    
    //
    //
    //
    // increment all 4 numberOfComments list fields by 1.
    // increment lists collection
    let commentIncrementDict: Dictionary<String, Any> = [
        "numberOfComments": FieldValue.increment(Int64(1))
    ]
    
    db.collection("lists").document(docId).updateData(commentIncrementDict) { (error) in
        if let error = error {
            print("Error incrementing comment count in lists collection:", error)
        }
    }
    
    // increment respective category
    db.collection(categoryString).document(docId).updateData(commentIncrementDict) { (error) in
        if let error = error {
            print("Error incrementing comment count in category collection:", error)
        }
    }
    
    // increment respective user
    db.collection("users").document(docUid).collection("lists").document(docId).updateData(commentIncrementDict) { (error) in
        if let error = error {
            print("Error incrementing comment count in user:", error)
        }
    }
    
    // increment respective user's respective category collection
    db.collection("users").document(docUid).collection(categoryString).document(docId).updateData(commentIncrementDict) { (error) in
        if let error = error {
            print("Error incrementing comment count in user's category:", error)
        }
    }
    //
    //
    //
    
}

func getListComments(docId: String, complete: @escaping ([Dictionary<String, Any>]) -> ()) {
    
    let listRef = db.collection("lists").document(docId)
    let commentsRef = listRef.collection("comments")
    let orderedCommentsRef = commentsRef.order(by: "timestamp", descending: false)
    
    orderedCommentsRef.getDocuments { (querySnapshot, error) in
        
        var lists: [Dictionary<String, Any>] = []
        
        if let error = error {
            print("Error getting list comments: \(error)")
        } else {
            for doc in querySnapshot!.documents {
                
                let docDict = doc.data()
                lists.append(docDict)
                
            }
        }
        
        complete(lists)
        
    }
    
}

func getNotifications(uid: String, complete: @escaping ([Dictionary<String, Any>]) -> ()) {
    
    let userRef = db.collection("users").document(uid)
    let notificationsRef = userRef.collection("notifications")
    let orderedNotificationsRef = notificationsRef.order(by: "timestamp", descending: true).limit(to: 50)
    
    orderedNotificationsRef.getDocuments { (querySnapshot, error) in
        
        var notifications: [Dictionary<String, Any>] = []
        
        if let error = error {
            print("Error getting notifications: \(error)")
        } else {
            for doc in querySnapshot!.documents {
                
                let docDict = doc.data()
                notifications.append(docDict)
                
            }
        }
        
        complete(notifications)
        
    }
    
}

func getSingleList(docId: String, complete: @escaping (Dictionary<String, Any>?) -> ()) {
    
    let listRef = db.collection("lists").document(docId)
    
    listRef.getDocument { (doc, error) in
        
        if let error = error {
            print("Error getting single list: \(error)")
            complete(nil)
        }
        
        complete(doc?.data())
        
    }
    
}

func getCircleUser(currentUid: String, otherUid: String, complete: @escaping (Dictionary<String, Any>?) -> ()) {
    
    let userRef = db.collection("users").document(currentUid).collection("circleUsers").document(otherUid)
    
    userRef.getDocument { (doc, error) in
        
        if let error = error {
            print("Error getting circle user: \(error)")
            complete(nil)
        }
        
        complete(doc?.data())
        
    }
    
}

// BEGIN circle invitations

func inviteToCircle(currentUser: Dictionary<String, String>, otherUser: Dictionary<String, String>) {
    
    guard let currentUid = currentUser["uid"] else { return } // use for docId in otherUser's circleUsers collections
    guard let currentUsername = currentUser["username"] else { return } // just check if it exists
    let currentProfileImgUrl = currentUser["profileImgUrl"]
    
    guard let otherUid = otherUser["uid"] else { return } // use for docId in currentUser's circleUsers collections
    guard let _ = otherUser["username"] else { return } // just check if it exists
    
    // set the isInvite bool and timestamp on each dict
    var newCurrentUser: Dictionary<String, Any> = currentUser
    var newOtherUser: Dictionary<String, Any> = otherUser
    
    let timestamp = Timestamp(date: Date())
    newCurrentUser["isInvite"] = true
    newCurrentUser["timestamp"] = timestamp
    newOtherUser["isInvite"] = true
    newOtherUser["timestamp"] = timestamp
    
    let currentUserCircleRef = db.collection("users").document(currentUid).collection("circleUsers").document(otherUid)
    let otherUserCircleRef = db.collection("users").document(otherUid).collection("circleUsers").document(currentUid)
    
    currentUserCircleRef.setData(newOtherUser) { (error) in
        if let error = error {
            print("Error sending circle invite to self:", error)
        }
    }
    
    otherUserCircleRef.setData(newCurrentUser) { (error) in
        if let error = error {
            print("Error sending circle invite to user:", error)
        }
    }
    
    // add an invite notification to the otherUser's notifications collection.
    var inviteNotificationDict: Dictionary<String, Any> = [
        "timestamp": timestamp,
        "senderUsername": currentUsername,
        "senderUid": currentUid,
        //"comment": comment,
        "receiverUid": otherUid,
        //"listDocId": nil,
        "type": notificationTypeToString(type: .invite),
        "isRead": false,
        //"docId": commentDocId,
        //"category": nil
    ]
    if let currentProfileImgUrl = currentProfileImgUrl {
        inviteNotificationDict["profileImgUrl"] = currentProfileImgUrl
    }
    
    db.collection("users").document(otherUid).collection("notifications").document(currentUid).setData(inviteNotificationDict) { (error) in
        if let error = error {
            print("Error adding invite notification to user:", error)
        }
    }
    
}

func removeFromCircle(currentUid: String, otherUid: String) {
    
    let currentUserCircleRef = db.collection("users").document(currentUid).collection("circleUsers").document(otherUid)
    let otherUserCircleRef = db.collection("users").document(otherUid).collection("circleUsers").document(currentUid)
    
    currentUserCircleRef.delete { (error) in
        if let error = error {
            print("Error deleting circleUser from self \(error)")
        }
    }
    
    otherUserCircleRef.delete { (error) in
        if let error = error {
            print("Error deleting circleUser from user \(error)")
        }
    }
    
}

// END circle invitations
