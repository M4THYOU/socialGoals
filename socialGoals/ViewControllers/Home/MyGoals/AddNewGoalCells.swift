//
//  AddNewGoalCells.swift
//  socialGoals
//
//  Created by Matthew Wolfe on 2019-08-14.
//  Copyright © 2019 Matthew Wolfe. All rights reserved.
//

import UIKit

struct NewListCellData {
    let title: String
}

class GoalFieldCell: UITableViewCell {
    
    var data: NewListCellData? {
        didSet {
            
            guard let data = data else { return }
            
            titleLabel.text = data.title
            
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        
        return label
    }()
    
    let goalTextView: UITextView = {
        let tv = UITextView()
        
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.isScrollEnabled = false
        
        return tv
    }()
    
    /******************************/
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .white
        
        separatorInset = .zero
        layoutMargins = .zero
        
        accessoryType = .disclosureIndicator
        
        goalTextView.delegate = self
        
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /******************************/
    
    func setupViews() {
        
        addSubview(titleLabel)
        addSubview(goalTextView)
        
        _ = titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        _ = goalTextView.anchor(top: topAnchor, left: titleLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
    }
    
}

extension GoalFieldCell: UITextViewDelegate {
    
    // Allows for auto sizing of the textview in tableview
    func textViewDidChange(_ textView: UITextView) {
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView?.beginUpdates()
            tableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            
            if let thisIndexPath = tableView?.indexPath(for: self) {
                tableView?.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
            }
            
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberofChars = newText.count
        
        return numberofChars < 120
        
    }
    
}

extension GoalFieldCell: NewListTableViewGoalDelegateA {
    func getGoalA() -> String? {
        return goalTextView.text
    }
}

extension GoalFieldCell: NewListTableViewGoalDelegateB {
    func getGoalB() -> String? {
        return goalTextView.text
    }
}

extension GoalFieldCell: NewListTableViewGoalDelegateC {
    func getGoalC() -> String? {
        return goalTextView.text
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////

class CategoryFieldCell: UITableViewCell {
    
    let categories: [ListCategory] = [.daily, .weekly]//, .monthly, .yearly, .career, .financial, .personaldev, .relationship, .health]
    var currentCategory: ListCategory = .daily
    
    var data: NewListCellData? {
        didSet {
            
            //guard let data = data else { return }
            //titleLabel.text = data.title
            
            // titleLabel.text is set in init!!!
            
        }
    }
    
    let titleTextField: UITextField = {
        let tf = UITextField()
        
        tf.textColor = .black
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.tintColor = .clear
        
        return tf
    }()
    
    let categoryPicker: UIPickerView = {
        let picker = UIPickerView()
        
        return picker
    }()
    
    /******************************/
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .white
        
        separatorInset = .zero
        layoutMargins = .zero
        
        
        titleTextField.text = listCategoryToString(category: categories[0])
        currentCategory = .daily
        
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /******************************/
    
    func setupViews() {
        
        titleTextField.inputView = categoryPicker
        
        addSubview(titleTextField)
        
        _ = titleTextField.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        //titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
}

extension CategoryFieldCell: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
}

extension CategoryFieldCell: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return listCategoryToString(category: categories[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        titleTextField.text = listCategoryToString(category: categories[row])
        currentCategory = categories[row]
    }
    
}

extension CategoryFieldCell: NewListTableViewCategoryDelegate {
    func getCategory() -> ListCategory {
        return currentCategory
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////

class PrivacyFieldCell: UITableViewCell {
    
    let privacies: [ListPrivacy] = [ListPrivacy.public_, ListPrivacy.circle, ListPrivacy.myself]
    var currentPrivacy: ListPrivacy {
        get {
            return privacies[privacySelector.selectedSegmentIndex]
        }
    }
    
    var data: NewListCellData? {
        didSet {
            
            //guard let data = data else { return }
            
            //titleLabel.text = data.title
            
        }
    }
    
    let privacySelector: UISegmentedControl = {
        let sc = UISegmentedControl()
        
        sc.tintColor = Colors.brandTurquoiseBlue
        
        return sc
    }()
    
    /******************************/
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .white
        
        separatorInset = .zero
        layoutMargins = .zero
        
        privacySelector.insertSegment(withTitle: listPrivacyToString(privacy: privacies[0]), at: 0, animated: false)
        privacySelector.insertSegment(withTitle: listPrivacyToString(privacy: privacies[1]), at: 1, animated: false)
        privacySelector.insertSegment(withTitle: listPrivacyToString(privacy: privacies[2]), at: 2, animated: false)
        privacySelector.selectedSegmentIndex = 0
        
        setupViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /******************************/
    
    func setupViews() {
        
        addSubview(privacySelector)
        
        _ = privacySelector.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        privacySelector.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
    }
    
}

extension PrivacyFieldCell: NewListTableViewPrivacyDelegate {
    func getPrivacy() -> ListPrivacy {
        return currentPrivacy
    }
}
