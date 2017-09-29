//
//  RerportTableViewCell.swift
//  dees
//
//  Created by Leonardo Durazo on 18/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import KDLoadingView
class RerportTableViewCell: UITableViewCell, ReportBindible, UITextViewDelegate {
    
    var report: Report!
    @IBOutlet weak var operativeTxv: UITextView!
    @IBOutlet weak var financialTxv: UITextView!
    @IBOutlet weak var observationsTxv: UITextView!
    @IBOutlet weak var loadingView: KDLoadingView!
    @IBOutlet weak var filesF: UIButton!
    @IBOutlet weak var filesOp: UIButton!
    @IBOutlet weak var replyF: UIButton!
    @IBOutlet weak var replyOp: UIButton!
    @IBOutlet weak var observationTitle: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        operativeTxv.delegate = self
        financialTxv.delegate = self
        observationsTxv.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
 
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView {
        case operativeTxv:
            report.operative = textView.text
            break
        case financialTxv:
            report.financial = textView.text
            break
        case observationsTxv:
            report.observations = textView.text
            break
        default:
            break
        }
        update()
    }
    
    func update() -> Void {
        store.dispatch(ReportsAction.Post(report: report))
    }
}
