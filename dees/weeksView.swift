//
//  weeksView.swift
//  dees
//
//  Created by Leonardo Durazo on 22/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit

class weeksView: UIView {
    let tapRight = UITapGestureRecognizer()
    let tapLeft = UITapGestureRecognizer()
    var titleView : titleNavBarView!
    
    let nextView : UIImageView = {
        let next = UIImageView()
        next.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        next.image = #imageLiteral(resourceName: "foward").maskWithColor(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
        next.isUserInteractionEnabled = true
        return next
    }()
    
    let leftView : UIImageView = {
        let left = UIImageView()
        left.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        left.image = #imageLiteral(resourceName: "back").maskWithColor(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
        left.isUserInteractionEnabled = true
        return left
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    func configureView(_ ctrl: weekProtocol) {
        
        tapRight.addTarget(ctrl, action: #selector(ctrl.tapRightWeek))
        tapLeft.addTarget(ctrl, action: #selector(ctrl.tapLeftWeek))
        backgroundColor = UIColor.clear
        nextView.addGestureRecognizer(tapRight)
        leftView.addGestureRecognizer(tapLeft)
        
        let tap = UITapGestureRecognizer(target: ctrl, action: #selector(ctrl.selectWeek))
        
        titleView.addGestureRecognizer(tap)
        titleView.isUserInteractionEnabled = true
        frame = CGRect(x:-30, y:0, width: titleView.frame.width+30, height:30)

        nextView.frame.origin.x = titleView.frame.width
        leftView.frame.origin.x =  titleView.frame.origin.x - 30
        titleView.frame.origin.x = (frame.width - titleView.frame.width)/2
        
        addSubview(titleView)
        addSubview(leftView)
        addSubview(nextView)
        titleView.isUserInteractionEnabled = true

    }
    
    override func draw(_ rect: CGRect) {
        frame = bounds
    }
}
extension weeksView {
    public func setTitle(title: String, subtitle: String, controller: weekProtocol) -> Void {
        
        titleView = {
            let titleView = titleNavBarView(title: title, subtitle: subtitle)
            return titleView
        }()
        
        configureView(controller)
    }
}
