//
//  Addons.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-10.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

class ErrorLabel: UILabel {
    
    /******************************/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textColor = Colors.warningRed
        font = UIFont.systemFont(ofSize: 11, weight: UIFont.Weight(rawValue: 0.2))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /******************************/
    
}

class LeftPaddedTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }
    
}

class CommentTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width - 10, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width - 10, height: bounds.height)
    }
    
}

class CheckBox: UIButton {
    
    let checkImage = #imageLiteral(resourceName: "checkmark.png")
    let uncheckedImage = #imageLiteral(resourceName: "unchecked.png")
    
    var listIndex: Int?
    
    var isChecked: Bool = false {
        didSet {
            
            if isChecked == true {
                self.setImage(checkImage, for: .normal)
            } else {
                self.setImage(uncheckedImage, for: .normal)
            }
            
        }
    }
    
    /******************************/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        self.setImage(uncheckedImage, for: .normal)
        isChecked = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /******************************/
    
    @objc func buttonClicked(sender: UIButton) {
        
        if sender == self {
            isChecked = !isChecked
        }
        
    }
    
}
