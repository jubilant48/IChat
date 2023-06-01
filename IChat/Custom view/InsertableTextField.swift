//
//  InsertableTextField.swift
//  IChat
//
//  Created by macbook on 08.01.2023.
//

import UIKit

// MARK: - Class

final class InsertableTextField: UITextField {
    // MARK: - Properties
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if isEmoji {
                if mode.primaryLanguage == "emoji" {
                    self.isEmoji = false
                    return mode
                }
            }
        }
        return nil
    }
    
    private var isEmoji: Bool = false
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .getTextFieldColor()
        placeholder = "Write something here ..."
        font = UIFont.systemFont(ofSize: 14)
        clearButtonMode = .whileEditing
        borderStyle = .none
        layer.cornerRadius = 18
        layer.masksToBounds = true
        
        let leftButton = UIButton(type: .system)
        leftButton.setImage(UIImage(systemName: "smiley"), for: .normal)
        leftButton.tintColor = .lightGray
        leftButton.addTarget(self, action: #selector(showEmoji), for: .touchUpInside)
        
        leftView = leftButton
        leftView?.frame = CGRect(x: 0, y: 0, width: 19, height: 19)
        leftViewMode = .always
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Sent"), for: .normal)
        button.applyGradients(cornerRadius: 10)
        
        rightView = button
        rightView?.frame = CGRect(x: 0, y: 0, width: 19, height: 19)
        rightViewMode = .always
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func showEmoji() {
        self.isEmoji = true
        self.becomeFirstResponder()
    }
    
    // MARK: - Methods
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        
        rect.origin.x += 12
        
        return rect
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        
        rect.origin.x += -12
        
        return rect
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 42, dy: 0)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 42, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 42, dy: 0)
    }
}
