//
//  CLPullDownToExplodeView.swift
//  pullDownToExplode
//
//  Created by 蔡磊 on 16/6/12.
//  Copyright © 2016年 cailei. All rights reserved.
//

import UIKit

let appWidth = UIScreen.mainScreen().bounds.width
let appHeight = UIScreen.mainScreen().bounds.height
    
class CLPullDownToExplodeView: UIView {
    
    //MARK:property
    
    //count of items
    var numberOfItem:Int = 15
    
    var isAnimating = false

    //MARK:lazy loading
    lazy var animator:UIDynamicAnimator = UIDynamicAnimator(referenceView: self)
    
    var progressView = UIView()
    
    var progress:CGFloat {
        
        set(newValue) {
            
            if self.isAnimating == false{
                progressView.transform = CGAffineTransformMakeScale(newValue, newValue)
                progressView.alpha = newValue
                progressView.layer.cornerRadius = 50*newValue*0.5
            }
            
        }
        get{
            return 1
        }
    }

    
    //MARK:init
    init(){
        super.init(frame: CGRectZero)
        prepareView()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:UI
    private func prepareView() -> Void{
        self.backgroundColor = UIColor.whiteColor()
        
        self.bounds = CGRect(x: 0, y: 0, width: appWidth, height: 300)
    }
    
    private func setupUI() -> Void{
        
        //progressView
        addSubview(progressView)
        
        progressView.center = CGPoint(x: appWidth*0.5, y: 250)
        progressView.backgroundColor = UIColor.redColor()
        progressView.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
        progressView.clipsToBounds = true
        progressView.alpha = 0
        
    }
    
    //MARK: explosion animation
    func explosion() -> Void{
        
        //小球乱跳动画
        let itemBehavior = UIDynamicItemBehavior()
        let gravity = UIGravityBehavior()
        let collision = UICollisionBehavior()
        
        for _ in 0...numberOfItem{
            
            //randomize the startColor and endColor
            let startColor = UIColor(red: CGFloat(arc4random_uniform(256))/256, green: CGFloat(arc4random_uniform(256))/256, blue: CGFloat(arc4random_uniform(256))/256, alpha: 1).CGColor
            let endColor = UIColor(red: CGFloat(arc4random_uniform(256))/256, green: CGFloat(arc4random_uniform(256))/256, blue: CGFloat(arc4random_uniform(256))/256, alpha: 1).CGColor
            
            let itemView = CLPullDownToExplodeViewItem(StartColor: startColor, EndColor: endColor)
            
            self.addSubview(itemView)
            let xOffset = Int(arc4random_uniform(200))
            let yOffset = Int(arc4random_uniform(200))
            itemView.frame = CGRect(x: 50+xOffset, y: 50+yOffset, width: 20, height: 20)
            itemBehavior.addItem(itemView)
            
            let velocityOffsetX = CGFloat(arc4random_uniform(100))
            let velocityOffsetY = CGFloat(arc4random_uniform(100))
            
            itemBehavior.addLinearVelocity(CGPointMake(-50+velocityOffsetX, -50+velocityOffsetY), forItem: itemView)
            
            let angularVelocityOffset = CGFloat(arc4random_uniform(UInt32(M_PI*2)))
            itemBehavior.addAngularVelocity(CGFloat(CGFloat(-M_PI)+angularVelocityOffset), forItem: itemView)
            gravity.addItem(itemView)
            collision.addItem(itemView)
        }
        
        //MARK:设置物理引擎
        itemBehavior.allowsRotation = true
        itemBehavior.elasticity = 0.9
        itemBehavior.friction = 0
        itemBehavior.density = 0.5
        itemBehavior.resistance = 0.05
        itemBehavior.angularResistance = 0.05
        
        
        // magnitude越大，速度增长越快
        gravity.magnitude = 0.5
        // 添加元素 告诉仿真器哪些元素添加重力行为,创建碰撞行为
        // 设置碰撞的边界
        collision.translatesReferenceBoundsIntoBoundary = true
        
        // 3.开始仿真
        // 添加到仿真器中开始仿真
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        animator.addBehavior(itemBehavior)
        
        //progressView小球爆炸动画
        UIView.animateWithDuration(0.25, animations: { 
            self.progressView.alpha = 0
            self.progressView.transform = CGAffineTransformMakeScale(0, 0)
            }) { (stop) in
                self.progressView.transform = CGAffineTransformIdentity
        }
        
        self.isAnimating = true

    }
    
    //结束爆炸动画
    func endExplosion() -> Void{
        
        animator.removeAllBehaviors()
        for subView in self.subviews{
            UIView.animateWithDuration(0.25, animations: {
                
                if (subView as UIView) != self.progressView{
                    (subView as UIView).alpha = 0
                    (subView as UIView).bounds = CGRectZero
                }

                }, completion: { (stop) in
                    if (subView as UIView) != self.progressView{
                        (subView as UIView).removeFromSuperview()
                    }
            })
            
        }
        
    }
    

}

class CLPullDownToExplodeViewItem: UIView {
    
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .Ellipse
    }
    
    //MARK:property
    var startColor:CGColor?
    var endColor:CGColor?
    
    //MARK:init
    init(){
        super.init(frame: CGRectZero)
        prepareView()
        setupUI()
    }
    
    init(StartColor startColor:CGColor,EndColor endColor:CGColor){
        super.init(frame: CGRectZero)
        self.startColor = startColor
        self.endColor = endColor
        
        prepareView()
        setupUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:UI
    private func prepareView() -> Void{
        
        self.backgroundColor = UIColor.lightGrayColor()
        self.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
    
    private func setupUI() -> Void{
        
        //add gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: -20, y: 0, width: 60, height: 20)
        gradientLayer.startPoint = CGPointMake(0, 0)
        gradientLayer.endPoint = CGPointMake(1, 1)
        gradientLayer.locations = [0.0,1.0]
        gradientLayer.colors = [startColor!,endColor!]
        self.layer.addSublayer(gradientLayer)
        
    }
}
    

