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
        
    }
}
