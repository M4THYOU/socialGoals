//
//  MyCircleCell.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-26.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

class MyCircleCell: UICollectionViewCell {
    
    var data: MyCircleCellData? {
        didSet {
            
            guard let data = data else { return }
            
            if let profileImgString = data.profileImgString {
                let imgRef = getImgRef(imageUrl: profileImgString)
                let placeholder = #imageLiteral(resourceName: "default-profile-pic.jpg")
                profileImgView.sd_setImage(with: imgRef, placeholderImage: placeholder)
            }
            
            let username = data.username
            usernameLabel.text = username
            
        }
    }
    
    let profileImgView: UIImageView = {
        let image = #imageLiteral(resourceName: "default-profile-pic")
        let iv = UIImageView()
        
        iv.image = image
        iv.layer.borderWidth = 1
        iv.layer.masksToBounds = false
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.cornerRadius = 25 // (50 / 2)
        iv.clipsToBounds = true
        
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        
        label.text = "\t"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = Colors.brandTurquoiseBlue
        
        return label
    }()
    
    /****************************************************************************************/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        layer.borderWidth = 0.5
        layer.borderColor = Colors.almostWhiteDarker.cgColor
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /****************************************************************************************/
    
    func setupViews() {
        
        addSubview(profileImgView)
        addSubview(usernameLabel)
        
        _ = profileImgView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        profileImgView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _ = usernameLabel.anchor(top: profileImgView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        usernameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }
    
}


