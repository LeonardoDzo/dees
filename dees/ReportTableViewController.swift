//
//  ReportTableViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 24/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import KDLoadingView
import Whisper

protocol reportDelegate: class {
    var report: Report! {get set}
}

class ReportTableViewController: UITableViewController,ReportBindible,UIGestureRecognizerDelegate, reportDelegate {
    var loading : KDLoadingView! = nil
    var report: Report!
    var user: User!
    var business: Business!
    var week: Week!
    
    let titlesSections = ["","Operativo","Financiero","Observaciones","Anexos"]
    
    @IBOutlet weak var UserLbl: UILabel!
    @IBOutlet weak var enterpriseLbl: UILabel!
    @IBOutlet weak var operativeTxv: UITextView!
    @IBOutlet weak var financialTxv: UITextView!
    @IBOutlet weak var observationsTxv: UITextView!
    @IBOutlet weak var colorLbl: UILabel!
    @IBOutlet weak var replySwt: UISwitch!
    @IBOutlet weak var anexosLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let rect = CGRect(x: self.tableView.frame.width/2, y: self.tableView.frame.height/2, width: 100, height: 100)
        loading = KDLoadingView(frame: rect)
        setupNavBar()
        setupBack()
        //loading.hidesWhenStopped = true
        self.hideKeyboardWhenTappedAround()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        store.dispatch(rAction.Get(eid: business.id, wid: week.id))
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        store.subscribe(self) {
            $0.select({
                s in s.reportState
            })
        }
        
        UserLbl.text = user.name!
        enterpriseLbl.text = business.name!
        if business.color != nil {
            colorLbl.backgroundColor = UIColor(hexString: "#\(business.color! )ff")
        }
    }
    
    @IBAction func replyChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.performSegue(withIdentifier: "replySegue", sender: self)
        }
    }
    func popUpController()
    {
        if store.state.userState.user.rol == .Superior {
            self.performSegue(withIdentifier: "replySegue", sender: self)
            return
        }
        
        let alertController = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let margin:CGFloat = 8.0
        let rect = CGRect(x:margin,y: margin, width: alertController.view.bounds.size.width - margin * 4.0, height: 120.0)
        let customView = UITextView(frame: rect)
        
        customView.backgroundColor = UIColor.white
        customView.formatView()
        customView.font = UIFont(name: "Helvetica", size: 15)
        customView.text = report.replyTxt ?? "No contiene"
        
        customView.isEditable = false
        //  customView.backgroundColor = UIColor.greenColor()
        alertController.view.addSubview(customView)
      
      
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in print("cancel")})
        
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion:{})
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "anexoSegue" {
            let vc = segue.destination as! AnexosTableViewController
            vc.report = report
        }else if segue.identifier == "replySegue" {
            if let nb = segue.destination as? UINavigationController {
                if let vc = nb.childViewControllers[0] as? ReplyViewController {
                    vc.delegate = sender as! ReportTableViewController
                }
            }
        }
    }
    
    func setupNavBar() -> Void {
        let saveBtn = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        
        self.navigationItem.rightBarButtonItems = [saveBtn]
        
        self.navigationItem.titleView =  UIView().setTitle(title: "Reporte:", subtitle:  (Date(string:week.startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:week.endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!)
    }
    
    func save() -> Void {
        report.financial = financialTxv.text
        report.operative = operativeTxv.text
        report.observations = observationsTxv.text
        report.reply = replySwt.isOn
        store.dispatch(rAction.Post(report: self.report))
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if report.files.count == 0 {
            return
        }else if indexPath.section == 4{
            self.performSegue(withIdentifier: "anexoSegue", sender: nil)
        }
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let view = UIView()
        view.tintColor = #colorLiteral(red: 0.08339247853, green: 0.1178589687, blue: 0.1773400605, alpha: 1)
        view.backgroundColor = #colorLiteral(red: 0.08339247853, green: 0.1178589687, blue: 0.1773400605, alpha: 1)
        let myCustomView = UIImageView(frame: CGRect(x: 5, y: 19, width: 40, height: 12))
        myCustomView.image = #imageLiteral(resourceName: "bullet")
        view.addSubview(myCustomView)
        let lbl = UILabel()
        lbl.text = titlesSections[section]
        lbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        lbl.frame = CGRect(x: 50, y: 16, width: Int(self.view.frame.width - 35), height: 20)
        view.addSubview(lbl)
        
        return view

    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section > 0 ? 44 : 0
    }
    
}
extension ReportTableViewController: StoreSubscriber {
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
            let notButton = UIBarButtonItem(image: #imageLiteral(resourceName: "notification"), style: .plain, target: self, action: #selector( self.popUpController))
            if !(self.report.replyTxt?.isEmpty)! && (self.navigationItem.rightBarButtonItems?.count)! < 2 && report.reply! {
                self.navigationItem.rightBarButtonItems?.append(notButton)
                if store.state.userState.user.rol != .Superior {
                   popUpController()
                }
            }
            self.bind()
            self.tableView.reloadData()
            break
        }
        
    }
}


