//
//  BedgeLabel + Extension.swift
//  IChat
//
//  Created by macbook on 12.05.2023.
//

import UIKit
import QuartzCore

// MARK: - Class

final class BadgeLabel: UILabel {
    // MARK: - Enumeration
    
    enum IntValueResult {
        case success(Int)
        case failure(Error)
    }
    
    // MARK: - Properties
    
    private var padding: CGFloat = 12
    
    // increase content size to account for padding
    override var intrinsicContentSize: CGSize {
        var content = super.intrinsicContentSize
        content.width += padding
        return content
    }
    
    private var convertTextToInt: IntValueResult {
        guard let text = text,
              let intVal = Int(text)
        else {
            let textValue = "\(text ?? "value")"
            let domain = "\(#function), \(textValue) cannot be converted to Int"
            let error = NSError(domain: domain, code: 0)
            return .failure(error)
        }
        return .success(intVal)
    }
    
    private var gradientView: GradientView!
    
    // MARK: - Init
    
    /// programmatic init
    ///   - Parameters:
    ///      - padding: The amount of padding from
    ///   the edges of the label to the text,
    ///   required to maintain circular shape
    ///   without clipping text
    init(backgroundColor: UIColor = .systemRed, text: String, padding: CGFloat = 12) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = backgroundColor
        self.text = text
        self.padding = padding
        self.font = UIFont.systemFont(ofSize: 14)
        
        commonInit()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: - Life cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        clipShape()
    }
    
    override func drawText(in rect: CGRect) {
        let insets = padWithInsets()
        super.drawText(in: rect.inset(by: insets))
    }
    
    // MARK: - Methods
    
    /// align text in the center of the label
    /// to avoid clipping and maintain visual
    /// consistency
    private func commonInit() {
        textAlignment = .center
    }
    
    /// - set the label's cornerRadius to make a circle
    /// - mask and clip to bounds to preserve circular
    /// shape without allowing other elements to bleed
    /// outside of the bounds of the shape
    private func clipShape() {
        let cornerRadius = 0.25 * bounds.size.width
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        clipsToBounds = true
    }
    
    /// add padding (half of class property to each side)
    private func padWithInsets() -> UIEdgeInsets {
        UIEdgeInsets(top: 0,
                     left: padding / 2,
                     bottom: 0,
                     right: padding / 2)
    }
    
    // MARK: - Badge Functionality
    
    /// set the label's text with `value`
    func set(_ value: String) {
        text = value
    }
    
    /// remove the label from its superview
    func remove() {
        removeFromSuperview()
    }
    
    /// increment the current value by `num`
    @discardableResult public func incrementIntValue(by num: Int) -> IntValueResult {
        switch convertTextToInt {
        case let .success(value):
            let totalValue = value.advanced(by: num)
            text = String(totalValue)
            return .success(totalValue)
        case let .failure(error):
            return .failure(error)
        }
    }
}


