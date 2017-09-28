//
//  enterpiseTitleView.swift
//  dees
//
//  Created by Leonardo Durazo on 22/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit

class enterpiseTitleView: UIView {
    let tapRight = UITapGestureRecognizer()
    let tapLeft = UITapGestureRecognizer()
    
    let nextView : UIImageView = {
        let next = UIImageView()
        next.frame = CGRect(x: 0, y: 12, width: 20, height: 20)
        next.image = #imageLiteral(resourceName: "foward").maskWithColor(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
        next.isUserInteractionEnabled = true
        return next
    }()
    
    let leftView : UIImageView = {
        let left = UIImageView()
        left.frame = CGRect(x: 0, y: 12, width: 20, height: 20)
        left.image = #imageLiteral(resourceName: "back").maskWithColor(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
        left.isUserInteractionEnabled = true
        return left
    }()
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init(frame: CGRect, title: String, controller: EnterpriseProtocol) {
        super.init(frame: frame)
        setTitle(title, controller)
    }
    func configureView(_ ctrl: EnterpriseProtocol) {
        let tap = UITapGestureRecognizer(target: ctrl, action: #selector(ctrl.selectEnterprise))
        tapLeft.addTarget(ctrl, action:  #selector(ctrl.tapLeft))
        tapRight.addTarget(ctrl, action: #selector(ctrl.tapRight))
        let border = UIView()
        border.frame = CGRect(x: 0, y: 39, width: frame.width, height: 5)
        border.backgroundColor = UIColor(hexString: "#\(ctrl.enterprises[ctrl.enterpriseSelected].color! )ff")
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tap)
        nextView.addGestureRecognizer(tapRight)
        leftView.addGestureRecognizer(tapLeft)
        titleLabel.frame.origin.x = frame.width/2-titleLabel.frame.width/2
        titleLabel.addGestureRecognizer(tap)
        titleLabel.frame.origin.y = 12
        leftView.frame.origin.x = 10
        nextView.frame.origin.x = frame.width - 30
       
        backgroundColor = UIColor.clear
        if ctrl.enterprises.count == 1 {
            nextView.isHidden = false
            leftView.isHidden = false
        }
        
        if ctrl.enterpriseSelected == ctrl.enterprises.count-1 {
            nextView.isHidden = true
        }
        if ctrl.enterpriseSelected == 0{
            leftView.isHidden = true
        }
        
        
        addSubview(border)
        addSubview(titleLabel)
        addSubview(nextView)
        addSubview(leftView)
        isUserInteractionEnabled = true
    }
    
    override func draw(_ rect: CGRect) {
        frame = bounds
        
    }
}
extension enterpiseTitleView {
    public func setTitle(_ title: String, _ controller: EnterpriseProtocol) -> Void {
        titleLabel.textColor = UIColor.white
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        configureView(controller)
    }
}

