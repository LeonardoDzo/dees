//
//  RerportTableViewCell.swift
//  dees
//
//  Created by Leonardo Durazo on 18/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import MIBadgeButton_Swift
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
    @IBOutlet weak var replyF: UIButtonX!
    @IBOutlet weak var replyOp: UIButtonX!
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
        go(to: .OPERATIVE, for: .filesView)
    }
    @IBAction func handleClickFi_Files(_ sender: UIButton) {
        go(to: .FINANCIAL, for: .filesView)
    }
    @IBAction func handleClickOp_Reply(_ sender: UIButton) {
        go(to: .OPERATIVE, for: .chatView)
    }
    
    @IBAction func handleClickFi_Reply(_ sender: UIButton) {
        go(to: .FINANCIAL, for: .chatView)
    }
    func go(to type: TYPE_ON_REPORT, for t: RoutingDestination) -> Void {
        let conf = configuration(uid: self.report.uid, wid: report.wid, type: type.rawValue, eid: report.eid, files: report.files, user: nil )
        
        if report != nil {
            gotoProtocol.goTo(t, sender: conf)
        }
        
    }
    func update() -> Void {
        if report != nil {
            store.dispatch(ReportsAction.Post(report: report))
        }
    }
    func updateMessages() -> Void {
        replyOp.setTitle("\(getMessages(type: 0))", for: .normal)
        replyF.setTitle("\(getMessages(type: 1))", for: .normal)
        
    }
    func getMessages(type: Int) -> Int {
        var count =  0
        if report != nil {
            let groups = realm.realm.objects(Group.self).filter("companyId  = %@ AND userId = %@ AND type = %@", report.eid, report.uid, type)
            
            groups.forEach({ (g) in
                let userin_times = g._party.first(where: {$0.id == store.state.userState.user.id})?.timestamp
                g._messages.forEach({ (m) in
                    if userin_times! < m.timestamp {
                        count += 1
                    }
                    
                })
            })
            if !store.state.userState.user.isDirectorCeo(), groups.toArray(ofType: Group.self).filter({$0.type == type }).count == 0  {
                if type == 0 {
                    replyOp.isHidden = true
                }else{
                    replyF.isHidden = true
                }
            }else{
                if type == 0 {
                    replyOp.isHidden = false
                }else{
                    replyF.isHidden = false
                }
            }
        }
        
        return count
    }
}
