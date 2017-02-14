//
//  ZYDrawerSpringAnimator.swift
//  a
//
//  Created by MAC on 2017/2/14.
//  Copyright © 2017年 TongBuWeiYe. All rights reserved.
//

import UIKit

class ZYDrawerSpringAnimator: NSObject {
    let kZYCenterViewDestinationScale:CGFloat = 0.7
    
    public var animationDelay: TimeInterval        = 0.0
    public var animationDuration: TimeInterval     = 0.7
    public var initialSpringVelocity: CGFloat      = 9.8
    public var springDamping: CGFloat              = 0.8
    
    public func applyTransforms(side: ZYDrawerSide, drawerView: UIView, centerView: UIView) {
        let direction = side.rawValue
        let sideWidth = drawerView.bounds.width
        let centerWidth = centerView.bounds.width
        let centerHorizontalOffset = direction * sideWidth
        let scaledCenterViewHorizontalOffset = direction * (sideWidth - (centerWidth - kZYCenterViewDestinationScale * centerWidth) / 2.0)
        
        let sideTransform = CGAffineTransform(translationX: centerHorizontalOffset, y: 0.0)
        drawerView.transform = sideTransform
        
        let centerTranslate = CGAffineTransform(translationX: scaledCenterViewHorizontalOffset, y: 0.0)
        let centerScale = CGAffineTransform(scaleX: kZYCenterViewDestinationScale, y: kZYCenterViewDestinationScale)
        centerView.transform = centerScale.concatenating(centerTranslate)
    }
    public func resetTransforms(views: [UIView]) {
        for view in views {
            view.transform = .identity
        }
    }
}
extension ZYDrawerSpringAnimator: ZYDrawerAnimating {
    public func openDrawer(side: ZYDrawerSide, drawerView: UIView, centerView: UIView, animated: Bool, complete: @escaping (_ finished: Bool) -> Void) {
        if (animated) {
            UIView.animate(withDuration: animationDuration, delay: animationDelay, usingSpringWithDamping: springDamping, initialSpringVelocity: initialSpringVelocity, options: UIViewAnimationOptions.curveLinear, animations: {
                self.applyTransforms(side: side, drawerView: drawerView, centerView: centerView)
            }, completion: complete)
        } else {
            self.applyTransforms(side: side, drawerView: drawerView, centerView: centerView)
        }
    }
    public func dismissDrawer(side: ZYDrawerSide, drawerView: UIView, centerView: UIView, animated: Bool, complete: @escaping (_ finished: Bool) -> Void) {
        if (animated) {
            UIView.animate(withDuration: animationDuration, delay: animationDelay, usingSpringWithDamping: springDamping, initialSpringVelocity: initialSpringVelocity, options: UIViewAnimationOptions.curveLinear, animations: {
                self.resetTransforms(views: [drawerView, centerView])
            }, completion: complete)
        } else {
            self.resetTransforms(views: [drawerView, centerView])
        }
    }
    public func willRotateWithDrawerOpen(side: ZYDrawerSide, drawerView: UIView, centerView: UIView) {
        
    }
    public func didRotateWithDrawerOpen(side: ZYDrawerSide, drawerView: UIView, centerView: UIView) {
        UIView.animate(withDuration: animationDuration, delay: animationDelay, usingSpringWithDamping: springDamping, initialSpringVelocity: initialSpringVelocity, options: UIViewAnimationOptions.curveLinear, animations: {}, completion: nil )
    }
}
public protocol ZYDrawerAnimating {
    func openDrawer(side: ZYDrawerSide, drawerView: UIView, centerView: UIView, animated: Bool, complete: @escaping(_ finished: Bool) -> Void)
    func dismissDrawer(side: ZYDrawerSide, drawerView: UIView, centerView: UIView, animated: Bool, complete: @escaping(_ finished: Bool) -> Void)
    func willRotateWithDrawerOpen(side: ZYDrawerSide, drawerView: UIView, centerView: UIView)
    func didRotateWithDrawerOpen(side: ZYDrawerSide, drawerView: UIView, centerView: UIView)
}
