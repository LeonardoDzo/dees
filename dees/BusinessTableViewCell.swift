//
//  BusinessTableViewCell.swift
//  dees
//
//  Created by Leonardo Durazo on 09/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class BusinessTableViewCell: UITableViewCell {

    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var colorLbl: UILabel!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
