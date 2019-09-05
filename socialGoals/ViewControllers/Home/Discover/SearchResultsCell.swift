//
//  SearchResultsTableViewCell.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-26.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

class SearchResultsCell: UITableViewCell {
    
    var data: SearchResultsCellData? {
        didSet {
            
            guard let data = data else { return }
            
            if let profileImgString = data.profileImgString {
                let imgRef = getImgRef(imageUrl: profileImgString)
                let placeholder = #imageLiteral(resourceName: "default-profile-pic.jpg")
                profileImgView.sd_setImage(with: imgRef, placeholderImage: placeholder)
            }
            
            usernameLabel.text = data.username
            
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
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        
        label.text = "\t"
        label.textColor = Colors.brandTurquoiseBlue
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return label
    }()
    
    /******************************/
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .white
        
        separatorInset = .zero
        layoutMargins = .zero
        
        accessoryType = .disclosureIndicator
        
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /******************************/
    
    func setupViews() {
        
        addSubview(profileImgView)
        addSubview(usernameLabel)
        
        _ = profileImgView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        profileImgView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        _ = usernameLabel.anchor(top: nil, left: profileImgView.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        usernameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
}
