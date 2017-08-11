//
//  ResponsableCollectionViewCell.swift
//  dees
//
//  Created by Leonardo Durazo on 09/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ResponsableCollectionViewCell: UICollectionViewCell, UserBindible {
    var user: User!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bind()
    }
}
