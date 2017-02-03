//
//  InstagramActivityIndicator.swift
//  InstagramActivityIndicator
//
//  Created by John Manos on 2/3/17.
//  Copyright © 2017 John Manos. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
public final class InstagramActivityIndicator: UIView {
    public var animationDuration: Double = 2
    public var rotationDuration: Double = 10
    @IBInspectable public var numSegments: Int = 12 {
        didSet {
            updateSegments()
        }
    }
    @IBInspectable public var strokeColor : UIColor = .blue {
        didSet {
            segmentLayer?.strokeColor = strokeColor.cgColor
        }
    }
    
    @IBInspectable public var lineWidth : CGFloat = 8 {
        didSet {
            segmentLayer?.lineWidth = lineWidth
            updateSegments()
        }
    }
    
    public var hidesWhenStopped: Bool = true
    public private(set) var isAnimating = false
    
    private weak var replicatorLayer: CAReplicatorLayer!
    private weak var segmentLayer: CAShapeLayer!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let replicatorLayer = CAReplicatorLayer()
        
        layer.addSublayer(replicatorLayer)
        
        let dot = CAShapeLayer()
        dot.lineCap = kCALineCapRound
        dot.strokeColor = strokeColor.cgColor
        dot.lineWidth = lineWidth
        dot.fillColor = nil
        //dot.backgroundColor = UIColor(white: 0.2, alpha: 0.2).cgColor
        
        replicatorLayer.addSublayer(dot)
        
        self.replicatorLayer = replicatorLayer
        self.segmentLayer = dot
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let maxRadius = max(0,min(bounds.width, bounds.height))/2
        replicatorLayer.bounds = CGRect.init(x: 0, y: 0, width: 2*maxRadius, height: 2*maxRadius)
        replicatorLayer.position = CGPoint(x: bounds.width/2, y:bounds.height/2)
        
        updateSegments()
    }
    
    private func updateSegments() {
        guard numSegments > 0, let segmentLayer = segmentLayer else { return }
        
        let angle = 2*CGFloat.pi / CGFloat(numSegments)
        replicatorLayer.instanceCount = numSegments
        replicatorLayer.instanceTransform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
        replicatorLayer.instanceDelay = animationDuration/Double(numSegments)
        
        let maxRadius = max(0,min(replicatorLayer.bounds.width, replicatorLayer.bounds.height))/2
        let radius: CGFloat = maxRadius - lineWidth/2
        
        segmentLayer.bounds = CGRect(x:0, y:0, width: 2*maxRadius, height: 2*maxRadius)
        segmentLayer.position = CGPoint(x: replicatorLayer.bounds.width/2, y: replicatorLayer.bounds.height/2)
        
        let path = UIBezierPath.init(arcCenter: CGPoint(x: maxRadius, y: maxRadius), radius: radius, startAngle: -angle/2 - CGFloat.pi/2, endAngle: angle/2 - CGFloat.pi/2, clockwise: true)
        
        segmentLayer.path = path.cgPath
    }
    
    public func startAnimating() {
        isAnimating = true
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.byValue = CGFloat.pi*2
        rotate.duration = rotationDuration
        rotate.repeatCount = Float.infinity
        
        let shrinkStart = CABasicAnimation(keyPath: "strokeStart")
        shrinkStart.fromValue = 0.0
        shrinkStart.toValue = 0.25
        shrinkStart.duration = animationDuration/2
        shrinkStart.autoreverses = true
        shrinkStart.repeatCount = Float.infinity
        shrinkStart.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let shrinkEnd = CABasicAnimation(keyPath: "strokeEnd")
        shrinkEnd.fromValue = 1.0
        shrinkEnd.toValue = 0.75
        shrinkEnd.duration = animationDuration/2
        //shrinkEnd.timeOffset = 1.0
        shrinkEnd.autoreverses = true
        shrinkEnd.repeatCount = Float.infinity
        shrinkEnd.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        replicatorLayer.add(rotate, forKey: "rotate")
        segmentLayer.add(shrinkStart, forKey: "start")
        segmentLayer.add(shrinkEnd, forKey: "end")
    }
    
    public func stopAnimating() {
        isAnimating = false
        replicatorLayer.removeAnimation(forKey: "rotate")
        segmentLayer.removeAnimation(forKey: "start")
        segmentLayer.removeAnimation(forKey: "end")
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 80, height: 80)
    }
}
