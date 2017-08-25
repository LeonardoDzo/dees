//
//  UIVIew.swift
//  dees
//
//  Created by Leonardo Durazo on 08/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit
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

   
}
