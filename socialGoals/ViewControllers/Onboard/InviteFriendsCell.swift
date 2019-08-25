//
//  InviteFriendsCell.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-10.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

protocol InviteFriendsCellDelegate: class {
    func showShareDialog()
}

class InviteFriendsCell: UICollectionViewCell {
    weak var delegate: InviteFriendsCellDelegate?
    
    let logoImageView: UIImageView = {
        let image = #imageLiteral(resourceName: "Logo-Main.png")
        let iv = UIImageView()
        
        iv.image = image
        
        return iv
    }()
    let logoName: UILabel = {
        let label = UILabel()
        
        label.text = "socialGoals"
        label.textAlignment = .center
        
        return label
    }()
    
    let inviteButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Invite your friends", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.brandTurquoiseBlue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        
        return button
    }()
    
    @objc func handleInviteButton() {
        
        if let del = delegate {
            del.showShareDialog()
        }
        
    }
    
    /****************************************************************************************/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        inviteButton.addTarget(self, action: #selector(handleInviteButton), for: .touchUpInside)
        
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /****************************************************************************************/
    
    func setupViews() {
        
        let screenWidth = UIScreen.main.bounds.width
        
        addSubview(logoImageView)
        addSubview(logoName)
        
        addSubview(inviteButton)
        
        _ = logoImageView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, topConstant: 80, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 160, heightConstant: 160)
        logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _ = logoName.anchor(top: logoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        _ = inviteButton.anchor(top: logoName.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 80, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: screenWidth - 80, heightConstant: 50)
        inviteButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }
    
}
