//
//  RerportTableViewCell.swift
//  dees
//
//  Created by Leonardo Durazo on 18/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import KDLoadingView
class RerportTableViewCell: UITableViewCell, ReportBindible {
    
    var report: Report!
    @IBOutlet weak var operativeTxv: UITextView!
    @IBOutlet weak var financialTxv: UITextView!
    @IBOutlet weak var observationsTxv: UITextView!
    @IBOutlet weak var loadingView: KDLoadingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
