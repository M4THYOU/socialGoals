//
//  NotificationCell.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-23.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit
import Mixpanel

protocol NotificationCellDelegate {
    func showProfileVC(username: String, isMyProfile: Bool)
}

class NotificationCell: UICollectionViewCell {
    
    var delegate: NotificationCellDelegate?
    var isAccepted: Bool?
    
    var data: NotificationCellData? {
        didSet {
            
            guard let data = data else { return }
            
            if let profileImgString = data.profileImgString {
                let imgRef = getImgRef(imageUrl: profileImgString)
                let placeholder = #imageLiteral(resourceName: "default-profile-pic.jpg")
                profileImgView.sd_setImage(with: imgRef, placeholderImage: placeholder)
            }
            
            
            let username = data.username
            let type = data.notificationType
            /*
            if let category = data.listCategory {
                backgroundColor = listCategoryToColor(category: category)
            }*/
            let isRead = data.isRead
            
            usernameButton.setTitle(username, for: .normal)
            
            if type == .comment {
                let notificationText = "commented on your list"
                notificationLabel.text = notificationText
            } else if type == .invite {
                let notificationText = "invited you to their circle"
                notificationLabel.text = notificationText
            }
            
            if type == .invite {
                addSubview(acceptButton)
                _ = acceptButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: -15, widthConstant: 0, heightConstant: 0)
                acceptButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
                
                if isRead {
                    acceptButton.setTitle("Accepted", for: .normal)
                    acceptButton.setTitleColor(.white, for: .normal)
                    acceptButton.backgroundColor = Colors.brandTurquoiseBlue
                }
                
                isAccepted = isRead
                
            }
            
        }
    }
    
    let profileImgView: UIImageView = {
        let image = #imageLiteral(resourceName: "default-profile-pic")
        let iv = UIImageView()
        
        iv.image = image
        iv.layer.borderWidth = 1
        iv.layer.masksToBounds = false
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.cornerRadius = 15 // (30 / 2)
        iv.clipsToBounds = true
        
        return iv
    }()
    
    let usernameButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("\t", for: .normal)
        button.setTitleColor(Colors.brandTurquoiseBlue, for: .normal)
        button.backgroundColor = .none
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        return button
    }()
    
    let notificationLabel: UILabel = {
        let label = UILabel()
        
        label.text = "\t"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        
        return label
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle("Accept", for: .normal)
        button.setTitleColor(Colors.brandTurquoiseBlue, for: .normal)
        
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.brandTurquoiseBlue.cgColor
        
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        return button
    }()
    
    @objc func handleProfileClick() {
        guard let username = usernameButton.title(for: .normal) else { return }
        let isMyProfile = udGetUser()?.username == username
        
        showProfileVC(username: username, isMyProfile: isMyProfile)
    }
    
    @objc func handleAccept() {
        
        guard let isAccepted = isAccepted else { return }
        guard let data = data else { return }
        
        guard let currentUid = getUid() ?? udGetUser()?.uid else { return }
        let otherUid = data.uid
        
        Mixpanel.mainInstance().track(event: "NotificationsTabCell_invite_request_accpet_button_clicked")
        
        if !isAccepted { // if not accepted
            
            acceptButton.setTitle("Accepted", for: .normal)
            acceptButton.setTitleColor(.white, for: .normal)
            acceptButton.backgroundColor = Colors.brandTurquoiseBlue
            
            self.isAccepted = true
            
            updateCircleInvite(currentUid: currentUid, otherUid: otherUid, shouldAccept: true)
            
        } else {
            
            acceptButton.setTitle("Accept", for: .normal)
            acceptButton.setTitleColor(Colors.brandTurquoiseBlue, for: .normal)
            acceptButton.backgroundColor = .white
            
            self.isAccepted = false
            
            updateCircleInvite(currentUid: currentUid, otherUid: otherUid, shouldAccept: true)
            
        }
        
    }
    
    /****************************************************************************************/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
        
        usernameButton.addTarget(self, action: #selector(handleProfileClick), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /****************************************************************************************/
    
    func setupViews() {
        
        addSubview(profileImgView)
        addSubview(usernameButton)
        
        addSubview(notificationLabel)
        
        _ = profileImgView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 15, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        
        _ = usernameButton.anchor(top: nil, left: profileImgView.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        usernameButton.centerYAnchor.constraint(equalTo: profileImgView.centerYAnchor).isActive = true
        
        _ = notificationLabel.anchor(top: profileImgView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: -10, rightConstant: -10, widthConstant: 0, heightConstant: 0)
        
    }
    
    func showProfileVC(username: String, isMyProfile: Bool) {
        if let del = delegate {
            del.showProfileVC(username: username, isMyProfile: isMyProfile)
        }
    }
    
}

