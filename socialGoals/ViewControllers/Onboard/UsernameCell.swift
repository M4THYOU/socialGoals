//
//  UsernameCell.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-10.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

class UsernameCell: UICollectionViewCell {
    
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
    
    let usernameTextField: LeftPaddedTextField = {
        let textField = LeftPaddedTextField()
        
        textField.placeholder = "Pick a username"
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1
        
        textField.returnKeyType = .done
        
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        
        return textField
    }()
    
    let errorLabel: ErrorLabel = {
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let label = ErrorLabel(frame: frame)
        
        label.numberOfLines = 0
        
        return label
    }()
    
    /****************************************************************************************/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /****************************************************************************************/
    
    func setupViews() {
        
        addSubview(logoImageView)
        addSubview(logoName)
        
        addSubview(usernameTextField)
        addSubview(errorLabel)
        
        _ = logoImageView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, topConstant: 80, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 160, heightConstant: 160)
        logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        _ = logoName.anchor(top: logoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        _ = usernameTextField.anchor(top: logoName.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 80, leftConstant: 32, bottomConstant: 0, rightConstant: -32, widthConstant: 0, heightConstant: 50)
        
        _ = errorLabel.anchor(top: usernameTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 36, bottomConstant: 0, rightConstant: -32, widthConstant: 0, heightConstant: 0)
        
    }
    
}
