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
    weak var ctrl : weekProtocol!
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
    init(ctrl: weekProtocol) {
        super.init(frame: CGRect(x:-30, y:0, width: 160, height:30))
        self.ctrl = ctrl
        
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureView() {
        
        tapRight.addTarget(ctrl, action: #selector(ctrl.tapRightWeek))
        tapLeft.addTarget(ctrl, action: #selector(ctrl.tapLeftWeek))
        backgroundColor = UIColor.clear
        nextView.addGestureRecognizer(tapRight)
        leftView.addGestureRecognizer(tapLeft)
        leftView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: ctrl, action: #selector(ctrl.selectWeek))
        
        titleView.addGestureRecognizer(tap)
        titleView.isUserInteractionEnabled = true
        
        nextView.frame.origin.x = titleView.frame.width + 10
        leftView.frame.origin.x =  titleView.frame.origin.x - 10
        titleView.frame.origin.x += 15
        
        
        if ctrl.weeks.count <= 1 {
            nextView.isHidden = true
            leftView.isHidden = true
        }else if (ctrl.weekSelected == ctrl.weeks.count-1) {
            nextView.isHidden = false
            leftView.isHidden = true
        }else if ctrl.weekSelected == 0 {
            nextView.isHidden = true
            leftView.isHidden = false
        }
        
        
        
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
    public func setTitle(title: String, subtitle: String) -> Void {
        
        titleView = {
            let titleView = titleNavBarView(title: title, subtitle: subtitle)
            return titleView
        }()
        
        configureView()
    }
}
