//
//  GradientView.swift
//  IChat
//
//  Created by macbook on 29.12.2022.
//

import UIKit

// MARK: - Class

final class GradientView: UIView {
    // MARK:  - Enumerations
    
    enum Point {
        case topLeading
        case leading
        case bottomLeading
        case top
        case center
        case bottom
        case topTrailing
        case trailing
        case bottomTrailing
        
        var point: CGPoint {
            switch self {
            case .topLeading:
                return CGPoint(x: 0, y: 0)
            case .leading:
                return CGPoint(x: 0, y: 0.5)
            case .bottomLeading:
                return CGPoint(x: 0, y: 1.0)
            case .top:
                return CGPoint(x: 0.5, y: 0)
            case .center:
                return CGPoint(x: 0.5, y: 0.5)
            case .bottom:
                return CGPoint(x: 0.5, y: 1.0)
            case .topTrailing:
                return CGPoint(x: 1.0, y: 0.0)
            case .trailing:
                return CGPoint(x: 1.0, y: 0.5)
            case .bottomTrailing:
                return CGPoint(x: 1.0, y: 1.0)
            }
        }
    }
    
    // MARK: - Properties
    
    private let gradientLayer = CAGradientLayer()
    private var startColor: UIColor? {
        didSet {
            setupGradientColors(startColor: startColor, endColor: endColor)
        }
    }
    private var endColor: UIColor? {
        didSet {
            setupGradientColors(startColor: startColor, endColor: endColor)
        }
    }
    private var points: (from: Point, to: Point)!
    
    private let animateGradientLayer = CAGradientLayer()
    private var colors: [[CGColor]] = []
    private var colorIndex: Int = 0
    private var animatePoints: (from: Point, to: Point)!
    
    // MARK: - Life Cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
        animateGradientLayer.frame = bounds
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        animateGradient()
    }
    
    // MARK: - Init
    
    /// Create static gradient color.
    init(from: Point, to: Point, startColor: UIColor?, endColor: UIColor?) {
        self.init()
        
        setupGradient(from: from, to: to, startColor: startColor, endColor: endColor)
    }
    
    /// Create animate gradient color.
    init(colors: [[CGColor]], from: Point, to: Point) {
        self.init()
        
        set(colors: colors)
        setAnimate(points: (from, to))
        setupAnimate()
    }
    
    /// Flexible initializr, assisting create and static color or animate selected colors.
    convenience init(from: Point, to: Point, startColor: UIColor, endColor: UIColor, animate: Bool = true) {
        if animate {
            let firstColor = startColor.cgColor
            let secondColor = endColor.cgColor
            let colors: [[CGColor]] = [[firstColor, secondColor],
                                       [secondColor, firstColor]]
            
            self.init(colors: colors, from: from, to: to)
        } else {
            self.init(from: from, to: to, startColor: startColor, endColor: endColor)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        // This line for Interface Builder
        setupGradient(from: .leading, to: .trailing, startColor: startColor, endColor: endColor)
    }
    
    // MARK: - Static gradient methods
    
    private func setupGradient(from: Point, to: Point, startColor: UIColor?, endColor: UIColor?) {
        self.layer.addSublayer(gradientLayer)
        
        setupGradientColors(startColor: startColor, endColor: endColor)
        
        gradientLayer.startPoint = from.point
        gradientLayer.endPoint = to.point
    }
    
    private func setupGradientColors(startColor: UIColor?, endColor: UIColor?) {
        if let startColor = startColor, let endColor = endColor {
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        }
    }
    
    /// Sets points for static gradient.
    func set(points: (Point, Point)) {
        self.points = points
    }
    
    /// Sets colors for static gradient.
    func set(startColor: UIColor, endColor: UIColor) {
        self.startColor = startColor
        self.endColor = endColor
    }
    
    // MARK: - Animate gradient methods
    
    /// Sets colors for animation.
    func set(colors: [[CGColor]]) {
        self.colors = colors
    }
    
    /// Sets points for animation.
    func setAnimate(points: (Point, Point)) {
        self.animatePoints = points
    }
    
    /// Sets up animation and launches.
    func setupAnimate() {
        animateGradientLayer.colors = colors[colorIndex]
        animateGradientLayer.startPoint = animatePoints.from.point
        animateGradientLayer.endPoint = animatePoints.to.point
        animateGradientLayer.drawsAsynchronously = true
        self.layer.addSublayer(animateGradientLayer)
        
        animateGradient()
    }
    
    private func animateGradient() {
        if colorIndex < colors.count - 1 {
            colorIndex += 1
        } else {
            colorIndex = 0
        }
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.duration = 0.8
        gradientChangeAnimation.toValue = colors[colorIndex]
        gradientChangeAnimation.fillMode = .forwards
        gradientChangeAnimation.autoreverses = true
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientChangeAnimation.delegate = self
        
        animateGradientLayer.add(gradientChangeAnimation, forKey: "colorChange")
    }
}

// MARK: - Core animation animate delegate

extension GradientView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            colorIndex = 0
            animateGradientLayer.colors = colors[colorIndex]
            animateGradient()
        }
    }
}
