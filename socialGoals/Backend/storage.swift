//
//  storage.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-10.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import Foundation
import FirebaseStorage

let storage = Storage.storage()

func uploadProfileImg(uid: String, imageUrl: URL) {
    
    let storageRef = storage.reference()
    let profileImgsRef = storageRef.child("profile-img/" + uid + ".jpg")
    
    var profileImg: Data
    do {
        profileImg = try Data(contentsOf: imageUrl)
    } catch {
        print("Error converting image url to data")
        return
    }
    
    _ = profileImgsRef.putData(profileImg, metadata: nil) { (metadata, error) in
        
        if let error = error {
            print("Error uploading profile picture", error)
            return
        }
        
        profileImgsRef.downloadURL(completion: { (url, error) in
            
            if let error = error {
                print("Error getting profile picture url.", error)
                return
            }
            
            guard let downloadUrl = url else { return }
            setUserProfilePictureURL(uid: uid, url: downloadUrl.absoluteString)
            
        })
        
    }
    
}

func getImgRef(imageUrl: String) -> StorageReference {
    
    let imgRef = storage.reference(forURL: imageUrl)
    
    return imgRef
    
}
