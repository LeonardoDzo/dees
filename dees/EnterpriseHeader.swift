//
//  EnterpriseHeader.swift
//  dees
//
//  Created by Leonardo Durazo on 02/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class EnterpriseHeader: UITableViewHeaderFooterView {
    var ctrl: EnterpriseProtocol!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var fowardView: UIImageView!
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var borderColor: UILabel!
    

    func configureView() {
        let tap = UITapGestureRecognizer(target: ctrl, action: #selector(ctrl.selectEnterprise))
        let tapLeft = UITapGestureRecognizer(target: ctrl, action:  #selector(ctrl.tapLeft))
        let tapRight = UITapGestureRecognizer(target: ctrl, action: #selector(ctrl.tapRight))
        
        
        titleLbl.isUserInteractionEnabled = true
        titleLbl.addGestureRecognizer(tap)
        fowardView.image = fowardView.image?.maskWithColor(color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
        backView.image = backView.image?.maskWithColor(color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
        fowardView.addGestureRecognizer(tapRight)
        backView.addGestureRecognizer(tapLeft)
        titleLbl.addGestureRecognizer(tap)
        titleLbl.sizeToFit()
        contentView.backgroundColor = #colorLiteral(red: 0.06047932059, green: 0.07674958557, blue: 0.1134311184, alpha: 1)
        isUserInteractionEnabled = true
    }

    public func setTitle(_ title: String) -> Void {
        titleLbl.text = title
        if title.count >= 24 {
            titleLbl.font = titleLbl.font.withSize(11)
        }else{
            titleLbl.font = titleLbl.font.withSize(13)
        }
        borderColor.backgroundColor = UIColor(hexString: "#\(ctrl.enterprises[ctrl.enterpriseSelected].color! )ff")
        if ctrl.enterprises.count > 1 {
            fowardView.isHidden = false
            backView.isHidden = false
        }
        if ctrl.enterpriseSelected == 0 {
            backView.isHidden = true
        }
        if ctrl.enterpriseSelected == ctrl.enterprises.count-1 {
            fowardView.isHidden = true
        }else{
            fowardView.isHidden = false
        }
        fowardView.isUserInteractionEnabled = true
        backView.isUserInteractionEnabled = true
    }

}
