//
//  ListCell.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-12.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

protocol ListCellDelegate: class {
    func showProfileVC(username: String, isMyProfile: Bool)
    func showCommentsVC(uid: String, docId: String, categoryString: String)
}

class ListCell: UICollectionViewCell {
    
    var delegate: ListCellDelegate?
    
    var data: MyListCellData? {
        didSet {
            
            guard let data = data else { return }
            
            if let profileImgString = data.profileImgString {
                let imgRef = getImgRef(imageUrl: profileImgString)
                let placeholder = #imageLiteral(resourceName: "default-profile-pic.jpg")
                profileImgView.sd_setImage(with: imgRef, placeholderImage: placeholder)
            }
            
            let cellColor = listCategoryToColor(category: data.category)
            let categoryString = listCategoryToString(category: data.category)
            let numberOfCommentsString = String(data.numberOfComments) + " Comments"
            let username = data.username
            let goals = data.goals
            
            categoryLabel.text = categoryString
            self.backgroundColor = cellColor
            
            usernameButton.setTitle(username, for: .normal)
            
            commentsButton.setTitle(numberOfCommentsString, for: .normal)
            
            var currentGoalIndex = 0
            for (completion, description) in goals {
                
                if currentGoalIndex == 0 {
                    checkBoxA.isChecked = completion
                    checkBoxA.isHidden = false
                    goalA.text = description + "\n\n"
                } else if currentGoalIndex == 1 {
                    checkBoxB.isChecked = completion
                    checkBoxB.isHidden = false
                    goalB.text = description + "\n\n"
                } else if currentGoalIndex == 2 {
                    checkBoxC.isChecked = completion
                    checkBoxC.isHidden = false
                    goalC.text = description + "\n\n"
                }
                
                currentGoalIndex += 1
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
        iv.layer.cornerRadius = 25 // (25 / 2)
        iv.clipsToBounds = true
        
        return iv
    }()
    
    let usernameButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("\t", for: .normal)
        button.setTitleColor(Colors.brandTurquoiseBlue, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        return button
    }()
    
    let categoryContainer: UIView = {
        let view = UIView()
        
        view.backgroundColor = .white
        
        return view
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        
        label.text = "\t"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        
        return label
    }()
    
    let commentsButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("\t", for: .normal)
        button.setTitleColor(Colors.brandTurquoiseBlue, for: .normal)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        return button
    }()
    
    let goalsArea: UIView = {
        let view = UIView()
        
        view.backgroundColor = .white
        
        return view
    }()
    
    let goalA: UILabel = {
        let label = UILabel()
        
        label.text = "\n\n"
        //"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW\n" // 120
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        
        label.numberOfLines = 0
        
        return label
    }()
    
    let goalB: UILabel = {
        let label = UILabel()
        
        label.text = "\n\n"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        
        label.numberOfLines = 0
        
        return label
    }()
    
    let goalC: UILabel = {
        let label = UILabel()
        
        label.text = "\n\n"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        
        label.numberOfLines = 0
        
        return label
    }()
    
    let checkBoxA: CheckBox = {
        let checkbox = CheckBox()
        
        checkbox.listIndex = 0
        checkbox.isHidden = true
        checkbox.isUserInteractionEnabled = false
        
        return checkbox
    }()
    
    let checkBoxB: CheckBox = {
        let checkbox = CheckBox()
        
        checkbox.listIndex = 1
        checkbox.isHidden = true
        checkbox.isUserInteractionEnabled = false
        
        return checkbox
    }()
    
    let checkBoxC: CheckBox = {
        let checkbox = CheckBox()
        
        checkbox.listIndex = 2
        checkbox.isHidden = true
        checkbox.isUserInteractionEnabled = false
        
        return checkbox
    }()
    
    @objc func handleProfileClick() {
        guard let username = usernameButton.title(for: .normal) else { return }
        let isMyProfile = udGetUser()?.username == username
        
        showProfileVC(username: username, isMyProfile: isMyProfile)
    }
    
    @objc func handleCommentsButton() {
        guard let data = data else { return }
        
        let uid = data.uid
        guard let docId = data.docId else { return }
        let categoryString = listCategoryToString(category: data.category)
        
        showCommentsVC(uid: uid, docId: docId, categoryString: categoryString)
    }
    
    /****************************************************************************************/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Colors.almostWhite // update this based on category
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
        
        usernameButton.addTarget(self, action: #selector(handleProfileClick), for: .touchUpInside)
        commentsButton.addTarget(self, action: #selector(handleCommentsButton), for: .touchUpInside)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /****************************************************************************************/
    
    func setupViews() {
        
        addSubview(profileImgView)
        
        addSubview(usernameButton)
        
        addSubview(categoryContainer)
        addSubview(categoryLabel)
        
        addSubview(commentsButton)
        
        addSubview(goalsArea)
        goalsArea.addSubview(goalA)
        goalsArea.addSubview(goalB)
        goalsArea.addSubview(goalC)
        goalsArea.addSubview(checkBoxA)
        goalsArea.addSubview(checkBoxB)
        goalsArea.addSubview(checkBoxC)
        
        _ = profileImgView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, topConstant: -25, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        profileImgView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _ = usernameButton.anchor(top: profileImgView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        usernameButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _ = categoryLabel.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: -20, rightConstant: -25, widthConstant: 0, heightConstant: 0)
        
        _ = categoryContainer.anchor(top: categoryLabel.topAnchor, left: categoryLabel.leftAnchor, bottom: categoryLabel.bottomAnchor, right: categoryLabel.rightAnchor, topConstant: -5, leftConstant: -10, bottomConstant: 5, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        
        _ = commentsButton.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        commentsButton.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor).isActive = true
        
        /////
        
        _ = goalsArea.anchor(top: usernameButton.bottomAnchor, left: leftAnchor, bottom: categoryContainer.topAnchor, right: rightAnchor, topConstant: 10, leftConstant: 15, bottomConstant: -15, rightConstant: -15, widthConstant: 0, heightConstant: 0)
        
        _ = checkBoxA.anchor(top: goalsArea.topAnchor, left: goalsArea.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        _ = goalA.anchor(top: goalsArea.topAnchor, left: checkBoxA.rightAnchor, bottom: nil, right: goalsArea.rightAnchor, topConstant: 10, leftConstant: 7, bottomConstant: 0, rightConstant: -5, widthConstant: 0, heightConstant: 0)
        
        _ = checkBoxB.anchor(top: goalA.bottomAnchor, left: goalsArea.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        _ = goalB.anchor(top: goalA.bottomAnchor, left: checkBoxB.rightAnchor, bottom: nil, right: goalsArea.rightAnchor, topConstant: 0, leftConstant: 7, bottomConstant: 0, rightConstant: -5, widthConstant: 0, heightConstant: 0)
        
        _ = checkBoxC.anchor(top: goalB.bottomAnchor, left: goalsArea.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        _ = goalC.anchor(top: goalB.bottomAnchor, left: checkBoxC.rightAnchor, bottom: nil, right: goalsArea.rightAnchor, topConstant: 0, leftConstant: 7, bottomConstant: 0, rightConstant: -5, widthConstant: 0, heightConstant: 0)
        
    }
    
    func showProfileVC(username: String, isMyProfile: Bool) {
        if let del = delegate {
            del.showProfileVC(username: username, isMyProfile: isMyProfile)
        }
    }
    
    func showCommentsVC(uid: String, docId: String, categoryString: String) {
        if let del = delegate {
            del.showCommentsVC(uid: uid, docId: docId, categoryString: categoryString)
        }
    }
    
}
