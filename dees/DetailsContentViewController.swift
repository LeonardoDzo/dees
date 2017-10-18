//
//  DetailsContentViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 05/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

protocol ReportDetailBindilble: AnyObject {
    var report : Report! {get set}
    var type : String! {get set}
    var textViewDetails: UITextView! { get }
    var saveBtn: UIButton! {get}
}
extension ReportDetailBindilble {
    var textViewDetails : UITextView! {return nil}
    var saveBtn : UIButton! {return nil}
    func bind(by report: Report) -> Void {
        self.report = report
        bind()
    }
    func bind() -> Void {
        guard let report = report else {
            return
        }
        if let textViewDetails = self.textViewDetails {
            if store.state.userState.user.id == report.uid {
                self.saveBtn.isHidden = false
                textViewDetails.isEditable = true
            }else{
                self.textViewDetails.isEditable = true
                self.saveBtn.isHidden = false
                // self.textViewDetails.isEditable = false
            }
            switch type {
            case "Operativo":
                self.textViewDetails.text = report.operative
            case "Financiero":
                self.textViewDetails.text = report.financial
            case "Observaciones":
                if store.state.userState.user.permissions.contains(where: {$0.rid.rawValue > 601 }) {
                    self.saveBtn.isHidden = false
                    textViewDetails.isEditable = true
                }
                self.textViewDetails.text = report.observations
            default:
                break
            }
        }
    }
}



class DetailsContentViewController: UIViewController, UITextViewDelegate, ReportDetailBindilble {
    @IBOutlet weak var enterpriseTitle: UILabel!
    @IBOutlet weak var cancelImg: UIImageView!
    @IBOutlet weak var userLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var textViewDetails: UITextView!
    var report : Report!
    var enterprise: Business!
    var user: User!
    var type: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        textViewDetails.delegate = self
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var saveBtn: UIButton!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleLbl.text = type
        self.bind(by: self.report)
        enterpriseTitle.text = enterprise.name
        userLbl.text = user.name
        enterpriseTitle.layer.backgroundColor = UIColor(hexString: "#\(enterprise.color!)00")?.cgColor
    }

    @IBAction func handleDissmiss(_ sender: Any) {
       self.dismiss(animated: true, completion: nil)
    }
    @IBAction func handleSave(_ sender: UIButton) {
        store.dispatch(ReportsAction.Post(report: report))
        self.dismiss(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        switch type {
        case "Operativo":
            self.report.operative = textViewDetails.text
        case "Financiero":
            self.report.financial = textViewDetails.text
        case "Observaciones":
            self.report.observations = textViewDetails.text
        default:
            break
        }
    }
    @IBOutlet weak var contentView: DesignableView!
    
    override func keyboardWillHide(notification: Notification) {

            if self.contentView.frame.origin.y != 0 {
               
                self.contentView.frame.origin.y += 130
            }
    }
    override func keyboardWillShow(notification: Notification) {
        
            if self.contentView.frame.origin.y != 0 {
                 self.contentView.frame.origin.y -= 130
            }
        
        
    }

}
