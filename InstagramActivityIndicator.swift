//
//  InstagramActivityIndicator.swift
//  InstagramActivityIndicator
//
//  Created by John Manos on 2/3/17.
//  Copyright © 2017 John Manos. All rights reserved.
//

import UIKit
import QuartzCore

public class InstagramActivityIndicator: UIView {
    public var animationDuration: Double = 2
    public var rotationDuration: Double = 10
    public var hidesWhenStopped: Bool = true
    public private(set) var isAnimating = false
    public var numSegments: Int = 12
    
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
        
        self.replicatorLayer = replicatorLayer
        
        let dot = CAShapeLayer()
        dot.lineCap = kCALineCapRound
        dot.strokeColor = UIColor.blue.cgColor
        dot.lineWidth = 8
        dot.fillColor = nil
        
        replicatorLayer.addSublayer(dot)
        
        segmentLayer = dot
        
        updateSegments()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        replicatorLayer.bounds = bounds
        replicatorLayer.position = CGPoint(x: frame.width/2, y:frame.height/2)
        
        updateSegments()
    }
    
    private func updateSegments() {
        let angle = 2*CGFloat.pi / CGFloat(numSegments)
        replicatorLayer.instanceCount = numSegments
        replicatorLayer.instanceTransform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
        replicatorLayer.instanceDelay = animationDuration/Double(numSegments)
        
        let radius: CGFloat = max(0,min(replicatorLayer.bounds.width, replicatorLayer.bounds.height))
        let x =  radius * sin(angle/2)
        let y =  radius * cos(angle/2)
        let width = 2*x
        let height = radius - y
        
        segmentLayer.bounds = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        segmentLayer.position = CGPoint(x: bounds.width/2, y: bounds.height/2 - radius + height)
        
        let path = UIBezierPath(arcCenter: CGPoint(x:x, y:radius), radius: radius, startAngle: -angle/2 + 3*CGFloat.pi/2, endAngle: angle/2 + 3*CGFloat.pi/2, clockwise: true)
        
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
