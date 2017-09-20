//
//  UIVIew.swift
//  dees
//
//  Created by Leonardo Durazo on 08/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit


@objc
protocol weekProtocol : class {
    func tapRightWeek() -> Void
    func tapLeftWeek() -> Void
    var weekSelected : Int { get set}
    func changeWeek(direction: UISwipeGestureRecognizerDirection) -> Void
    func selectWeek() -> Void
}

@objc
protocol EnterpriseProtocol : class {
    func tapRight() -> Void
    func tapLeft() -> Void
    var  enterpriseSelected : Int { get set}
    func changeEnterprise(direction: UISwipeGestureRecognizerDirection) -> Void
    func selectEnterprise() -> Void
}


extension UIView {
    func formatView() -> Void {
        //self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor( red: 62/255, green: 69/255, blue:88/255, alpha: 1.0 ).cgColor
    }
    func profileUser() -> Void {
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
        //self.layer.borderWidth = 1.0

        //self.layer.borderColor = #colorLiteral(red: 0.2431372549, green: 0.2705882353, blue: 0.3450980392, alpha: 1).cgColor
    }
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame:  CGRect(x:0,y:-2,width: 0,height: 0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x:0,y:18,width: 0,height: 0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = #colorLiteral(red: 0.5450980392, green: 0.8274509804, blue: 0.9764705882, alpha: 1)
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x:0, y:0, width: max(titleLabel.frame.size.width,subtitleLabel.frame.size.width), height:30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        
        return titleView
    }
    
    func titleOfEnterprise(section: Int, controller: AllReportsTableViewController) -> UIView {
        let view = UIView()
        view.tintColor = #colorLiteral(red: 0.08339247853, green: 0.1178589687, blue: 0.1773400605, alpha: 1)
        view.backgroundColor = #colorLiteral(red: 0.08339247853, green: 0.1178589687, blue: 0.1773400605, alpha: 1)
        view.frame.size.width = controller.view.frame.width
        let next = UIImageView()
        next.frame = CGRect(x: Int(controller.view.frame.width-30), y: 12, width: 25, height: 15)
        next.image = #imageLiteral(resourceName: "foward").maskWithColor(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
        let tapRight = UITapGestureRecognizer(target: controller, action: #selector(controller.tapRight))
        next.isUserInteractionEnabled = true
        next.addGestureRecognizer(tapRight)
        
        let left = UIImageView()
        left.frame = CGRect(x: 10, y: 12, width: 25, height: 15)
        left.image = #imageLiteral(resourceName: "back").maskWithColor(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
        let tapLeft = UITapGestureRecognizer(target: controller, action: #selector(controller.tapLeft))
        left.isUserInteractionEnabled = true
        left.addGestureRecognizer(tapLeft)
        
        
        let lbl = UILabel()
        let border = UIView()
        border.frame = CGRect(x: 0, y: 39, width: Int(controller.view.frame.width), height: 5)
        border.backgroundColor = UIColor(hexString: "#\(controller.enterprises[section].color! )ff")
        
        let tap = UITapGestureRecognizer(target: controller, action: #selector(controller.selectEnterprise))
        
        let numberUser = controller.enterprises[section].users.count > 1 ? " (\(String(controller.enterprises[section].users.count)))" : ""
        lbl.text = controller.enterprises[section].name! + numberUser
        lbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        lbl.frame = CGRect(x: 0, y: 12, width: 0, height: 0)
        lbl.textAlignment = .center
        lbl.tag = section
        lbl.sizeToFit()
        lbl.frame.origin.x = CGFloat(Int(controller.view.frame.width/2)-Int(lbl.frame.width/2))
        
        lbl.addGestureRecognizer(tap)
        lbl.isUserInteractionEnabled = true
        
        view.addSubview(left)
        view.addSubview(next)
        view.addSubview(border)
        view.addSubview(lbl)
        
        return view

    }
    
    func setWeeks(title:String, subtitle:String, controller: weekProtocol) -> UIView {
        let tapRight = UITapGestureRecognizer(target: controller, action: #selector(controller.tapRightWeek))
        
        
        let next = UIImageView()
        next.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        next.image = #imageLiteral(resourceName: "foward").maskWithColor(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
        next.addGestureRecognizer(tapRight)
        next.isUserInteractionEnabled = true
        
        
        let left = UIImageView()
        left.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        left.image = #imageLiteral(resourceName: "back").maskWithColor(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
        let tapLeft = UITapGestureRecognizer(target: controller, action: #selector(controller.tapLeftWeek))
        left.addGestureRecognizer(tapLeft)
        left.isUserInteractionEnabled = true
        let view = self.setTitle(title: title, subtitle: subtitle)
        let tap = UITapGestureRecognizer(target: controller, action: #selector(controller.selectWeek))
        
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        let titleView = UIView(frame: CGRect(x:-20, y:0, width: view.frame.width+30, height:30))
        next.frame.origin.x = view.frame.width + 15
        left.frame.origin.x =  view.frame.origin.x - 15
        view.frame.origin.x = (titleView.frame.width - view.frame.width)/2
        titleView.addSubview(view)
        titleView.addSubview(left)
        titleView.addSubview(next)
        titleView.isUserInteractionEnabled = true
        return titleView
        
    }

   
}
