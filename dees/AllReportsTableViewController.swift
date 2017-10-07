//
//  AllReportsTableViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 11/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Whisper
protocol GoToProtocol :  class {
    func goTo(_ route: RoutingDestination, sender: Any?)
    func viewInfo(_ report: Report,_ type: String) -> Void
}

class AllReportsTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    var enterprises = [Business]()
    var type : Int!
    var user: User!
    var enterpriseSelected = 0
    var Bsection = -1
    var weeks = [Week]()
    var weekSelected: Int = 0
    var weeksTitleView : weeksView? = weeksView(frame: .zero)
    let notificationCenter = NotificationCenter.default
    var lastContentOffset: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConf()
        setupNavBar()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return enterprises.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResponsableTableViewCell
        cell.enterprise = enterprises[indexPath.section]
        cell.tag = self.weeks[self.weekSelected].id
        cell.gotoProtocol = self
        cell.changeEnterpriseProtocol = self
        cell.tableView.reloadData()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let e = enterprises[section]
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "EnterpriseHeaderCell")  as! EnterpriseHeader
        cell.ctrl = self
        cell.configureView()
        var name = e.name
        if store.state.businessState.business.count > 0 {
            name?.append(e.users.count > 1 ?" (\(e.users.count))" : "")
        }
        cell.borderColor.layer.backgroundColor = UIColor(hexString: "#\(e.color!)##")?.cgColor
        cell.setTitle(name!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func rotated() -> Void {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 575
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ResponsableTableViewCell {
            if cell.users.count > 0 {
                cell.lastsection = 0
                cell.tableView.scrollToRow(at: IndexPath(row: 0, section: cell.lastsection), at: .top, animated: false)
            }
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollTo(scrollView)
        }
    }
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollTo(scrollView)
    }
    func scrollTo(_ scrollView: UIScrollView) -> Void {
        var animation : UISwipeGestureRecognizerDirection = .down
        let visibleRect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let indexPath = tableView.indexPathForRow(at: visiblePoint){
            if enterpriseSelected < indexPath.section {
                animation = .right
            }else if enterpriseSelected > indexPath.section{
                animation = .left
            }
            changeEnterprise(direction: animation)
        }
    }
}

extension AllReportsTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = ReportState
    
    override func viewWillAppear(_ animated: Bool) {
        notificationCenter.addObserver(self, selector: #selector(AllReportsTableViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(AllReportsTableViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if type == nil {
            type = store.state.userState.type
        }else{
            store.state.userState.type = type
        }
        setVars()
        store.subscribe(self){
            $0.select({
                s in s.reportState
            })
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        changeEnterprise(direction: .down)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
        Whisper.hide(whisperFrom: self.navigationController!)
    }
    
    func newState(state: ReportState) {
        self.view.isUserInteractionEnabled = true
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: self.enterpriseSelected )) as? ResponsableTableViewCell else {
            return
        }
        cell.loadingView.stop()
        switch state.status {
        case .loading:
            self.view.isUserInteractionEnabled = false
            cell.loadingView.start()
            return
        case .finished:
            cell.updated()
            break
        case .Finished(let m as Murmur):
            Whisper.show(whistle: m, action: .show(2.5))
            cell.updated()
            break
        case .Failed(let m as Murmur):
            Whisper.show(whistle: m, action: .show(2.5))
            break
        case .failed:
            Whisper.show(whistle: messages.error._00, action: .show(2.5))
            break
        default:
            break
            
        }
        
    }
    
}
extension AllReportsTableViewController {
    func setupConf() -> Void {
        let nib = UINib(nibName: "EnterpriseHeader", bundle: nil)
        
        self.styleNavBarAndTab_1()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: "EnterpriseHeaderCell")
        self.hideKeyboardWhenTappedAround()
    }
    func setupNavBar() -> Void {
        let add = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.updateReport))
        self.navigationItem.rightBarButtonItem = add
    }
    func update() -> Void {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: self.enterpriseSelected )) as? ResponsableTableViewCell {
            cell.tag = self.weeks[self.weekSelected].id
            cell.enterprise = self.enterprises[self.enterpriseSelected]
            cell.tableView.reloadData()
             cell.getMyReports() 
        }
    }

    
    func updateReport() -> Void {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: self.enterpriseSelected )) as? ResponsableTableViewCell {
            cell.update()
        }
    }
    
    func setVars() -> Void {
        self.user = store.state.userState.user
        
        if enterprises.count == 0 {
            enterprises.removeAll()
            self.enterprises = store.state.businessState.business.count > 0 ? store.state.businessState.business.first(where: {$0.id == type})?.business ?? [] : store.state.userState.user.bussiness
            var count = -1
            self.enterprises.enumerated().forEach({
                index, b in
                count += 1
                b.business.enumerated().forEach( {
                    i, b1 in
                    count += 1
                    self.enterprises.insert(b1, at: count)
                })
            })
        }
        
        self.weeks = store.state.reportState.weeks
        didMove(toParentViewController: self)
       
        
    }
}

extension AllReportsTableViewController : weekProtocol {
    func changeWeek(direction : UISwipeGestureRecognizerDirection){
        var animation: UITableViewRowAnimation = .none
        if direction == .right {
            if weekSelected > 0 {
                animation = .left
                self.weekSelected -= 1
            }
        }else{
            if weekSelected < weeks.count-1 {
                animation = .right
                self.weekSelected += 1
            }
        }
        
        if animation != .none {
            didMove(toParentViewController: self)
            
            self.tableView.reloadSections(IndexSet(integer: self.enterpriseSelected), with: animation)
            update()
        }
    }
    func tapLeftWeek() {
        changeWeek(direction: .left)
    }
    
    func tapRightWeek() {
        changeWeek(direction: .right)
    }
    
    func selectWeek() {
        self.pushToView(view: .weeksView)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        self.navigationItem.titleView = nil
        if parent != nil && self.navigationItem.titleView == nil {
            weeksTitleView = weeksView(ctrl: self)
            
            weeksTitleView?.setTitle(title: "Reporte", subtitle:  (Date(string:self.weeks[self.weekSelected].startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:self.weeks[self.weekSelected].endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!)
            
            self.navigationItem.titleView = weeksTitleView
            
            self.navigationItem.titleView?.isUserInteractionEnabled = true
        }
    }
}

extension AllReportsTableViewController : EnterpriseProtocol {
    func showScrollOptions(sender: UISwipeGestureRecognizer) {
        changeEnterprise(direction: sender.direction == .right ? .left : .right)
    }
    
    func tapRight() {
        changeEnterprise(direction: .right)
    }
    func tapLeft() {
        changeEnterprise(direction: .left)
    }
    
    func changeEnterprise(direction: UISwipeGestureRecognizerDirection) {
        if direction == .left {
            self.enterpriseSelected  -= enterpriseSelected > 0 ?  1 : 0
        }else if direction == .right{
            self.enterpriseSelected += enterpriseSelected < enterprises.count-1 ? 1 : 0
        }
        let indexpath = IndexPath(row: 0, section: enterpriseSelected)
        self.lastContentOffset = CGFloat( self.enterpriseSelected * Int(self.tableView.rowHeight))
        self.tableView.scrollToRow(at: indexpath, at: .top, animated: true)
        
        
        update()
    }
    func selectEnterprise() {
        if enterprises.count >  1 {
            self.pushToView(view: .enterprises, sender: type)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewInfo" {
            if let data = sender as? [String:Any] {
                guard let report = data["report"] as? Report else {
                    return
                }
                guard let type = data["type"] as? String else {
                    return
                }
                
                if let vc = segue.destination as? DetailsContentViewController {
                    vc.report = report
                    vc.type = type
                    if let e = enterprises.first(where: {$0.id == report.eid}) {
                        vc.enterprise = e
                        vc.user = e.users.count > 0 ? e.users.first(where: {$0.id == report.uid}) : store.state.userState.user
                    }
                }
            }
        }
    }
}
extension AllReportsTableViewController : GoToProtocol {
    func goTo(_ route: RoutingDestination, sender: Any?) {
        guard var dic = sender as? [String : Any] else {
            return
        }
        dic["enterprise"] = self.enterprises[self.enterpriseSelected]
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: self.enterpriseSelected)) as? ResponsableTableViewCell {
            dic["user"] = cell.getUser()
        }
        
        self.pushToView(view: route, sender: dic)
    }
    func viewInfo(_ report: Report,_ type: String) {
        let data = [
            "report": report,
            "type": type
            ] as [String : Any]
        self.performSegue(withIdentifier: "viewInfo", sender: data)
    }
}
