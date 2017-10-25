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
    var gotoProtocol : GoToProtocol!
    @IBOutlet weak var operativeTxv: UITextView!
    @IBOutlet weak var financialTxv: UITextView!
    @IBOutlet weak var observationsTxv: UITextView!
    @IBOutlet weak var loadingView: KDLoadingView!
    @IBOutlet weak var filesF: UIButton!
    @IBOutlet weak var filesOp: UIButton!
    @IBOutlet weak var replyF: UIButton!
    @IBOutlet weak var replyOp: UIButton!
    @IBOutlet weak var observationTitle: UIStackView!
    
    @IBOutlet weak var operativeStack: UIStackView!
    @IBOutlet weak var financialStack: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        operativeTxv.delegate = self
        financialTxv.delegate = self
        observationsTxv.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        tap.numberOfTapsRequired = 1
        let tapOp = UITapGestureRecognizer(target: self, action: #selector(self.tapOp))
        tapOp.numberOfTapsRequired = 1
        let tapFi = UITapGestureRecognizer(target: self, action: #selector(self.tapFi))
        tapFi.numberOfTapsRequired = 1

        observationTitle.addGestureRecognizer(tap)
        observationTitle.isUserInteractionEnabled = true
        operativeStack.addGestureRecognizer(tapOp)
        operativeStack.isUserInteractionEnabled = true
        financialStack.addGestureRecognizer(tapFi)
        financialStack.isUserInteractionEnabled = true
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func textViewDidChange(_ textView: UITextView) {
        if report == nil {
            return
        }
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
    }
    @objc func tapOp() -> Void {
        self.viewDetail(to: "Operativo")
    }
    @objc func tapFi() -> Void {
        self.viewDetail(to:  "Financiero")
    }
    @objc func tap() -> Void {
        self.viewDetail(to: "Observaciones")
    }
    
    func viewDetail(to type: String) -> Void {
        if gotoProtocol != nil {
            gotoProtocol.viewInfo(self.report, type)
        }
    }
    
    @IBAction func handleClickOp_Files(_ sender: UIButton) {
        go(to: 0, for: 0)
    }
    @IBAction func handleClickFi_Files(_ sender: UIButton) {
        go(to: 1, for: 0)
    }
    @IBAction func handleClickOp_Reply(_ sender: UIButton) {
        go(to: 0, for: 1)
    }
    
    @IBAction func handleClickFi_Reply(_ sender: UIButton) {
        go(to: 1, for: 1)
    }
    func go(to type: Int, for t: Int) -> Void {
        let info = ["report": report,
                    "type": type] as [String : Any]
        if report != nil {
            gotoProtocol.goTo(t == 0 ? .filesView : .chatView, sender: info)
        }
        
    }
    func update() -> Void {
        if report != nil {
            store.dispatch(ReportsAction.Post(report: report))
        }
    }
}
