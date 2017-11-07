//
//  FBLoader.swift
//  FBAnimatedView
//
//  Created by Samhan on 08/01/16.
//  Copyright © 2016 Samhan. All rights reserved.
//

import UIKit

public extension UITableView
{
    public func ld_visibleContentViews()->[UIView]
    {
        
        return (self.visibleCells as NSArray).value(forKey: "contentView") as! [UIView]
        
    }
}

public extension UICollectionView
{
    public func ld_visibleContentViews()->[UIView]
    {
        
        return (self.visibleCells as NSArray).value(forKey: "contentView") as! [UIView]
        
    }
}

extension UIColor {
    
    static func backgroundFadedGrey()->UIColor
    {
        return UIColor(red: (246.0/255.0), green: (247.0/255.0), blue: (248.0/255.0), alpha: 1)
    }
    
    static func gradientFirstStop()->UIColor
    {
        return  UIColor(red: (238.0/255.0), green: (238.0/255.0), blue: (238.0/255.0), alpha: 1.0)
    }
    
    static func gradientSecondStop()->UIColor
    {
        return UIColor(red: (221.0/255.0), green: (221.0/255.0), blue:(221.0/255.0) , alpha: 1.0);
    }
}



public class Loader
{
    public static func addLoaderToViews( views : [UIView])
    {
        CATransaction.begin()
        views.forEach { $0.ld_addLoader() }
        CATransaction.commit()
    }
    
    public static func removeLoaderFromViews( views: [UIView])
    {
        CATransaction.begin()
        views.forEach { $0.ld_removeLoader() }
        CATransaction.commit()
    }

    public static func addLoaderToTableView( table : UITableView )
    {
        self.addLoaderToViews(views: table.ld_visibleContentViews())
    }
    
    public static func addLoaderToCollectionView( coll : UICollectionView )
    {
        self.addLoaderToViews(views: coll.ld_visibleContentViews())
    }

    public static func removeLoaderFromTableView( table : UITableView )
    {
        self.removeLoaderFromViews(views: table.ld_visibleContentViews())
    }
    
    public static func removeLoaderFromCollectionView( coll : UICollectionView )
    {
        self.removeLoaderFromViews(views: coll.ld_visibleContentViews())
    }

}

class CutoutView : UIView
{
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(UIColor.white.cgColor)
        
        context!.fill(self.bounds)
        
        for view in (self.superview?.subviews)! {
            
            if view != self {
                
                context!.setBlendMode(.clear);
                context!.setFillColor(UIColor.clear.cgColor)
                context!.fill(view.frame)
            }
        }
    }
}

var cutoutHandle: UInt8 = 0
var gradientHandle: UInt8 = 0

extension UIView
{
    public func ld_getCutoutView()->UIView?
    {
        return objc_getAssociatedObject(self, &cutoutHandle) as! UIView?
    }
    
    func ld_setCutoutView(aView : UIView)
    {
        return objc_setAssociatedObject(self, &cutoutHandle, aView, .OBJC_ASSOCIATION_RETAIN)
    }
    
    func ld_getGradient()->CAGradientLayer?
    {
        return objc_getAssociatedObject(self, &gradientHandle) as! CAGradientLayer?
    }
    
    func ld_setGradient(aLayer : CAGradientLayer)
    {
        return objc_setAssociatedObject(self, &gradientHandle, aLayer, .OBJC_ASSOCIATION_RETAIN)
    }
    
    public func ld_addLoader()
    {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRect(x:0, y:0, width:self.bounds.size.width ,height: self.bounds.size.height)
        
        
        self.configureAndAddAnimationToGradient(gradient: gradient)
        self.layer.insertSublayer(gradient, at:0)
        self.addCutoutView()
    }
    
    public func ld_removeLoader()
    {
        self.ld_getCutoutView()?.removeFromSuperview()
        self.ld_getGradient()?.removeAllAnimations()
        self.ld_getGradient()?.removeFromSuperlayer()
        
        for view in self.subviews {
            view.alpha = 1
        }
    }
    
    
    func configureAndAddAnimationToGradient( gradient : CAGradientLayer)
    {
       
        
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let colors = [UIColor.gray.cgColor, UIColor.white.cgColor, UIColor.gray.cgColor]
        gradient.colors = colors
        
        let locations = [0.25, 0.5, 0.75]
        gradient.locations = locations as [NSNumber]?
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Use image to create a mask on the gradient layer.
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.frame = bounds.offsetBy(dx: bounds.size.width, dy: 0)
        maskLayer.contents = image?.cgImage
        
        gradient.mask = maskLayer

        let gradientAnimation = CABasicAnimation(keyPath: "locations")
        gradientAnimation.fromValue = [0.0, 0.0, 0.25]
        gradientAnimation.toValue = [0.75, 1.0, 1.0]
        gradientAnimation.duration = 1.7
        gradientAnimation.repeatCount = Float.infinity
        gradientAnimation.isRemovedOnCompletion = false
        gradientAnimation.fillMode = kCAFillModeForwards
        gradient.add(gradientAnimation, forKey: nil)
        self.ld_setGradient(aLayer: gradient)
        
    }
    
    func addCutoutView()
    {
        let cutout = CutoutView()
        cutout.frame = self.bounds
        cutout.backgroundColor = UIColor.clear
        
        self.insertSubview(cutout, at: 1)
        cutout.setNeedsDisplay()
        
        
        for view in self.subviews {
            if view != cutout {
                view.alpha = 0
            }
        }
        self.ld_setCutoutView(aView: cutout)
    }
}

