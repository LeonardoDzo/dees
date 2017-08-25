 //
//  EnterpriseCollectionViewCell.swift
//  dees
//
//  Created by Leonardo Durazo on 23/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class EnterpriseCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var colorLbl: UILabel!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var imageCompany: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    func setupView() -> Void {
        var val = 50
        if self.frame.height > 300 && self.frame.height < 500 {
            val = 100
        }else if self.frame.height > 500 {
            val = 200
        }
        nameLbl.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        nameLbl.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageCompany.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        nameLbl.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        imageCompany.widthAnchor.constraint(equalToConstant: CGFloat(val)).isActive = true
        imageCompany.heightAnchor.constraint(equalToConstant: CGFloat(val)).isActive = true
    }
}
