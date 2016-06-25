//
//  FNMatchPullView.swift
//  FNMatchPull
//
//  Created by Fnoz on 16/6/25.
//  Copyright © 2016年 Fnoz. All rights reserved.
//

import UIKit

let horizontalMove = CGFloat(150.0)
let verticalMove = CGFloat(100.0)
let pullViewHeight = CGFloat(80.0)

class FNMatchPullView: UIView {
    
    var matchViews:NSMutableArray = []
    var startPoints:NSArray = []
    var endPoints:NSArray = []
    var timer:NSTimer!
    var progress:CGFloat = 0.0 {
        didSet {
            refreshView(progress)
        }
    }
    
    func initMatch() {
        if startPoints.count != endPoints.count || startPoints.count == 0{
            return
        }
        //remove old matchs
        if matchViews.count > 0 {
            for i in 0 ... matchViews.count - 1 {
                let match = matchViews[i] as! FNMatchPullMatch
                match.removeFromSuperview()
            }
        }
        
        matchViews.removeAllObjects()
        matchViews = NSMutableArray.init(array: [])
        //build new matchs
        for i in 0 ... startPoints.count - 1 {
            let match = FNMatchPullMatch.init()
            match.backgroundColor = UIColor.whiteColor()
            match.alpha = 0.3
            let startPoint = (startPoints[i] as! NSValue).CGPointValue()
            let endPoint = (endPoints[i] as! NSValue).CGPointValue()
            let aaa = (endPoint.x - startPoint.x)*(endPoint.x - startPoint.x)+(endPoint.y - startPoint.y)*(endPoint.y - startPoint.y)
            match.frame = CGRectMake(0, 0, sqrt(aaa), 2)
            if i%2 == 0 {
                match.center = CGPointMake((startPoint.x + endPoint.x)/2 - horizontalMove, (startPoint.y + endPoint.y)/2 - verticalMove)
            }
            else {
                match.center = CGPointMake((startPoint.x + endPoint.x)/2 + horizontalMove, (startPoint.y + endPoint.y)/2 - verticalMove)
            }
            match.oriCenter = match.center
            match.angle = atan((endPoint.y - startPoint.y)/(endPoint.x - startPoint.x)) + CGFloat(M_PI)
            match.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI) + match.angle)
            addSubview(match)
            matchViews.addObject(match)
        }
    }
    
    func refreshView(progress:CGFloat) {
        let validProgress = min(progress, 1.0)  //限制到1以下
        for i in 0 ... matchViews.count - 1 {
            let duration = 0.6
            let interval = CGFloat((1-duration)/Double(matchViews.count - 1))
            var progressHandled = (validProgress - CGFloat(i) * interval) / 0.6
            if progressHandled<0 {
                progressHandled = 0
            }
            else if progressHandled>1 {
                progressHandled = 1
            }
            let startPoint = (startPoints[i] as! NSValue).CGPointValue()
            let endPoint = (endPoints[i] as! NSValue).CGPointValue()
            let centerPoint = CGPointMake((startPoint.x + endPoint.x)/2, (startPoint.y + endPoint.y)/2)
            let newCenterPoint:CGPoint
            let match = matchViews[i] as! FNMatchPullMatch
            if i%2 == 0 {
                newCenterPoint = CGPointMake(centerPoint.x - horizontalMove * (1 - progressHandled), centerPoint.y - verticalMove * (1 - progressHandled))
                match.transform = CGAffineTransformMakeRotation(match.angle + CGFloat(M_PI) * progressHandled)
            }
            else {
                newCenterPoint = CGPointMake(centerPoint.x + horizontalMove * (1 - progressHandled), centerPoint.y - verticalMove * (1 - progressHandled))
                match.transform = CGAffineTransformMakeRotation(match.angle + CGFloat(M_PI) * progressHandled)
            }
            match.center = newCenterPoint
        }
    }
    
    func startBling() {
        timer = NSTimer.scheduledTimerWithTimeInterval(2.1,
                                                       target:self,selector:#selector(addAnimation),
                                                       userInfo:nil,repeats:true)
        timer.fire()
    }
    
    @objc func addAnimation() {
        let interval = 1.5/Double(matchViews.count)
        for i in 0 ... matchViews.count - 1 {
            let match = matchViews[i] as! FNMatchPullMatch
            UIView.animateWithDuration(0.3, delay: interval * Double(i), options: .CurveLinear, animations: {
                match.alpha = 1;
                }, completion: { (fff) in
                    UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
                        match.alpha = 0.3
                        }, completion: nil)
            })
        }
    }
    
    func endBling() {
        timer.invalidate()
        for i in 0 ... matchViews.count - 1 {
            let match = matchViews[i] as! FNMatchPullMatch
            match.layer.removeAllAnimations()
        }
    }
}