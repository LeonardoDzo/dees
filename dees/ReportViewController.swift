//
//  ReportViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 10/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import KDLoadingView
import Whisper
class ReportViewController: UIViewController,UITextViewDelegate, ReportBindible, UIGestureRecognizerDelegate {
    var report: Report!
    var user: User!
    var business: Business!
    var week: Week!
    
    //Outlets
    @IBOutlet weak var loading: KDLoadingView!
    @IBOutlet weak var UserLbl: UILabel!
    @IBOutlet weak var enterpriseLbl: UILabel!
    @IBOutlet weak var operativeTxv: UITextView!
    @IBOutlet weak var financialTxv: UITextView!
    @IBOutlet weak var observationsTxv: UITextView!
    @IBOutlet weak var colorLbl: UILabel!
    @IBOutlet weak var replySwt: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        loading.hidesWhenStopped = true
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: Notification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: Notification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        store.dispatch(GetReportsByEnterpriseAndWeek(eid: business.id, wid: week.id))
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        store.subscribe(self) {
            state in
            state.reportState
        }
        
        UserLbl.text = user.name!
        enterpriseLbl.text = business.name!
        
    }
    
    func setupNavBar() -> Void {
        let saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.navigationItem.rightBarButtonItem = saveBtn
        self.navigationItem.title = "Report"
    }
    
    func save() -> Void {
        report.financial = financialTxv.text
        report.operative = operativeTxv.text
        report.observations = observationsTxv.text
        report.reply = replySwt.isOn
        store.dispatch(SaveReportAction(report: self.report))
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < 501
    }


}
extension ReportViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = ReportState
    
    func newState(state: ReportState) {
        loading.stopAnimating()
        switch state.status {
        case .loading:
            loading.isHidden = false
            loading.startAnimating()
            break
        case .finished :
            // Present a permanent message
            Whisper.show(whisper: messages.succesG, to: navigationController!, action: .show)
            break
        case .failed :
             Whisper.show(whisper: messages.errorG, to: navigationController!, action: .show)
            break
        default:
            report = state.reports.first(where: {$0.eid == business.id && $0.wid == week.id && $0.uid == user.id })
            if report == nil {
                report = Report(uid: user.id!, eid: business.id!, wid: week.id!)
            }
            self.bind()
            break
        }
        
        
        
    }
}
