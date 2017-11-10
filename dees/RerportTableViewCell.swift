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
    @IBOutlet weak var filesF: MIBadgeButton!
    @IBOutlet weak var filesOp: MIBadgeButton!
    @IBOutlet weak var replyF: MIBadgeButton!
    @IBOutlet weak var replyOp: MIBadgeButton!
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
        let x = #imageLiteral(resourceName: "message-1").withRenderingMode(.alwaysTemplate).maskWithColor(color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
        let c = #imageLiteral(resourceName: "cabinet").withRenderingMode(.alwaysTemplate).maskWithColor(color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
        replyOp.setImage(x, for: UIControlState.normal)
        replyF.setImage(x, for: UIControlState.normal)
        filesF.setImage(c, for: .normal)
        filesOp.setImage(c, for: .normal)
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
        let conf = configuration(uid: self.report.uid, wid: report.wid, type: type, eid: report.eid, report:self.report, user: nil )
        
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
        
        
        let count = getMessages(type: 0)
        replyOp.badgeString = "\(count)"
        
        
        let countF : Int = getMessages(type: 1)
        replyF.badgeString = "\(countF)"
        
        
    }
    func getMessages(type: Int) -> Int {
        var count =  0
        if report != nil {
            
            let groups = realm.realm.objects(Group.self).filter("companyId  = %@ AND type = %@", report.eid, type)
            if groups.count == 0,  !store.state.userState.user.isDirectorCeo(){
                if type == 0 {
                    replyOp.isHidden = true
                }else{
                    replyF.isHidden = true
                }
               

            }else{
                if type == 1 {
                    replyF.isHidden = false
                }else{
                    replyOp.isHidden = false
                }
                if store.state.userState.user.isDirectorCeo() {
                    if let group = groups.filter("userId = %@",store.state.userState.user.id!).first {
                        if let userin_times = group._party.first(where: {$0.id == store.state.userState.user.id}) {
                            count = group._messages.filter("timestamp > %@", userin_times).count
                        }
                    }
                }else{
                    groups.forEach({ (group) in
                        if let userin_times = group._party.first(where: {$0.id == store.state.userState.user.id})?.timestamp {
                            count = group._messages.filter("timestamp > %@", userin_times).count
                        }
                    })
                }
            }
            
            
            
            
        }
        
        return count
    }
    
}
