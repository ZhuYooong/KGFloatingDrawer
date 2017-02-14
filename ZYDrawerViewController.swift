//
//  ZYDrawerViewController.swift
//  a
//
//  Created by MAC on 2017/2/14.
//  Copyright © 2017年 TongBuWeiYe. All rights reserved.
//

import UIKit

public enum ZYDrawerSide: CGFloat {
    case None  = 0
    case Left  = 1
    case Right = -1
}
class ZYDrawerViewController: UIViewController {
    let defaultDuration:TimeInterval = 0.3
    // MARK: Initialization
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func loadView() {
        view = drawerView
    } 
    private var _drawerView: ZYDrawerView?
    var drawerView: ZYDrawerView {
        get {
            if let retVal = _drawerView {
                return retVal
            }
            let rect = UIScreen.main.bounds
            let retVal = ZYDrawerView(frame: rect)
            _drawerView = retVal
            return retVal
        }
    }
    // MARK: Add ability to supply custom animator.
    private var _animator: ZYDrawerSpringAnimator?
    public var animator: ZYDrawerSpringAnimator {
        get {
            if let retVal = _animator {
                return retVal
            }
            let retVal = ZYDrawerSpringAnimator()
            _animator = retVal
            return retVal
        }
    }
    // MARK: Interaction
    @available(iOS, deprecated: 1.0, message: "Refresh Data")
    public func openDrawer(side: ZYDrawerSide, animated:Bool, complete: @escaping (_ finished: Bool) -> Void) {
        if currentlyOpenedSide != side {
            if let sideView = drawerView.viewContainerForDrawerSide(drawerSide: side) {
                let centerView = drawerView.centerViewContainer
                if currentlyOpenedSide != .None {
                    closeDrawer(side: side, animated: animated) { finished in
                        self.animator.openDrawer(side: side, drawerView: sideView, centerView: centerView, animated: animated, complete: complete)
                    }
                }else {
                    self.animator.openDrawer(side: side, drawerView: sideView, centerView: centerView, animated: animated, complete: complete)
                }
                addDrawerGestures()
                drawerView.willOpenDrawer(viewController: self)
            }
        }
//        if leftViewController! is ZYUserViewController {
//            (self.leftViewController as! ZYUserViewController).initData()
//        }
        currentlyOpenedSide = side
    }
    public func closeDrawer(side: ZYDrawerSide, animated: Bool, complete: @escaping (_ finished: Bool) -> Void) {
        if (currentlyOpenedSide == side && currentlyOpenedSide != .None) {
            if let sideView = drawerView.viewContainerForDrawerSide(drawerSide: side) {
                let centerView = drawerView.centerViewContainer
                animator.dismissDrawer(side: side, drawerView: sideView, centerView: centerView, animated: animated, complete: complete)
                currentlyOpenedSide = .None
                restoreGestures()
                drawerView.willCloseDrawer(viewController: self)
            }
        }
    }
    public func toggleDrawer(side: ZYDrawerSide, animated: Bool, complete: @escaping (_ finished: Bool) -> Void) {
        if side != .None {
            if side == currentlyOpenedSide {
                closeDrawer(side: side, animated: animated, complete: complete)
            } else {
                openDrawer(side: side, animated: animated, complete: complete)
            }
        }
    }
    // MARK: Gestures
    func addDrawerGestures() {
        centerViewController?.view.isUserInteractionEnabled = false
        drawerView.centerViewContainer.addGestureRecognizer(toggleDrawerTapGestureRecognizer)
    }
    func restoreGestures() {
        drawerView.centerViewContainer.removeGestureRecognizer(toggleDrawerTapGestureRecognizer)
        centerViewController?.view.isUserInteractionEnabled = true
    }
    func centerViewContainerTapped(sender: AnyObject) {
        closeDrawer(side: currentlyOpenedSide, animated: true) { (finished) -> Void in
            
        }
    }
    // MARK: Helpers
    func viewContainer(side: ZYDrawerSide) -> UIViewController? {
        switch side {
        case .Left:
            return self.leftViewController
        case .Right:
            return self.rightViewController
        case .None:
            return nil
        }
    }
    func replaceViewController(sourceViewController: UIViewController?, destinationViewController: UIViewController, container: UIView) {
        sourceViewController?.willMove(toParentViewController: nil)
        sourceViewController?.view.removeFromSuperview()
        sourceViewController?.removeFromParentViewController()
        
        self.addChildViewController(destinationViewController)
        container.addSubview(destinationViewController.view)
        
        let destinationView = destinationViewController.view
        destinationView?.translatesAutoresizingMaskIntoConstraints = false
        
        container.removeConstraints(container.constraints)
        
        let views: [String:UIView] = ["v1" : destinationView!]
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v1]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v1]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        destinationViewController.didMove(toParentViewController: self)
    }
    // MARK: Private computed properties
    public var currentlyOpenedSide: ZYDrawerSide = .None
    private var _leftViewController: UIViewController?
    public var leftViewController: UIViewController? {
        get {
            return _leftViewController
        }set {
            self.replaceViewController(sourceViewController: self.leftViewController, destinationViewController: newValue!, container: self.drawerView.leftViewContainer)
            _leftViewController = newValue!
        }
    }
    private var _rightViewController: UIViewController?
    public var rightViewController: UIViewController? {
        get {
            return _rightViewController
        }set {
            self.replaceViewController(sourceViewController: self.rightViewController, destinationViewController: newValue!, container: self.drawerView.rightViewContainer)
            _rightViewController = newValue
        }
    }
    private var _centerViewController: UIViewController?
    public var centerViewController: UIViewController? {
        get {
            return _centerViewController
        }set {
            self.replaceViewController(sourceViewController: self.centerViewController, destinationViewController: newValue!, container: self.drawerView.centerViewContainer)
            _centerViewController = newValue
        }
    }
    private lazy var toggleDrawerTapGestureRecognizer: UITapGestureRecognizer = {
        [unowned self] in
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ZYDrawerViewController.centerViewContainerTapped(sender:)))
        return gesture
        }()
    public var leftDrawerWidth: CGFloat {
        get  {
            return drawerView.leftViewContainerWidth
        }set {
            drawerView.leftViewContainerWidth = newValue
        }
    }
    public var rightDrawerWidth: CGFloat {
        get {
            return drawerView.rightViewContainerWidth
        }set {
            drawerView.rightViewContainerWidth = newValue
        }
    }
    public var leftDrawerRevealWidth: CGFloat {
        get {
            return drawerView.leftViewContainerWidth
        }
    }
    public var rightDrawerRevealWidth: CGFloat {
        get {
            return drawerView.rightViewContainerWidth
        }
    }
    public var backgroundImage: UIImage? {
        get {
            return drawerView.backgroundImageView.image
        }set {
            drawerView.backgroundImageView.image = newValue
        }
    }
}
