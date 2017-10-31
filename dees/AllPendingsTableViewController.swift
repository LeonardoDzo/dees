 //
 //  AllPendingsTableViewController.swift
 //  dees
 //
 //  Created by Leonardo Durazo on 18/10/17.
 //  Copyright © 2017 Leonardo Durazo. All rights reserved.
 //
 
 import UIKit
 import ReSwift
 import Whisper
 import AnimatableReload
 
 class AllPendingsTableViewController: UITableViewController {
    let notificationCenter = NotificationCenter.default
    var pendings = [pendingModel]()
    var enterpriseSelected = 0
    var weekSelected = 0
    lazy var weeksTitleView : weeksView? = weeksView(frame: .zero)
    /// variables no implementadas
    var weeks = [Week]()
    var enterprises = [Business]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConf()
        let add = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.updateReport))
        
        self.navigationItem.rightBarButtonItems = [add]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return pendings[enterpriseSelected].weeks.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pendings[enterpriseSelected].weeks[section].users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResponsableTableViewCell
        let pending = pendings[enterpriseSelected]
        cell.enterprise = pending.enterprise
        if let week = pending.weeks[weekSelected].week {
            cell.tag = week.id
            //cell.gotoProtocol = self
            cell.weekProtocol = self
            cell.users = pending.weeks[weekSelected].users
            cell.isPending = true
            cell.tableView.reloadData()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let week = pendings[enterpriseSelected].weeks[section].week
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "EnterpriseHeaderCell")  as! EnterpriseHeader
        cell.weekProtocol = self
        cell.configureView()
        let name = week?.getTitleOfWeek()
        cell.setTitle(name!)
        return cell
    }
    
    
    func setupConf() -> Void {
        let nib = UINib(nibName: "EnterpriseHeader", bundle: nil)
        
        self.styleNavBarAndTab_1()
        
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: "EnterpriseHeaderCell")
        self.hideKeyboardWhenTappedAround()
    }
    @objc func updateReport() -> Void {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: weekSelected)) as? ResponsableTableViewCell {
            cell.update()
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
        if let indexPath = tableView.indexPathForRow(at: visiblePoint) {
            if weekSelected < indexPath.section {
                animation = .right
            }else if weekSelected > indexPath.section{
                animation = .left
            }
            changeWeek(direction: animation)
        }
    }
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let indexPath = tableView.indexPathForRow(at: visiblePoint){
            if let cell = tableView.cellForRow(at: indexPath) as? ResponsableTableViewCell {
                let pending : pendingModel = self.pendings[enterpriseSelected]
                cell.tag = pending.weeks[weekSelected].week.id
                
                cell.enterprise = pending.enterprise
                cell.tableView.reloadData()
                cell.getMyReports()
            }
        }
    }
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ResponsableTableViewCell {
            if cell.users.count > 0 {
                cell.lastsection = 0
                cell.tableView.scrollToRow(at: IndexPath(row: 0, section: cell.lastsection), at: .top, animated: false)
                cell.tag = self.pendings[self.enterpriseSelected].weeks[weekSelected].week.id
                cell.enterprise = self.pendings[self.enterpriseSelected].enterprise
                cell.tableView.reloadData()
                cell.getMyReports()
            }
        }
    }
    
 }
 extension AllPendingsTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = ReportState
    
    override func viewWillAppear(_ animated: Bool) {
        notificationCenter.addObserver(self, selector: #selector(AllReportsTableViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(AllReportsTableViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        store.subscribe(self){
            $0.select({
                s in s.reportState
            })
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0,section: self.enterpriseSelected)) as? ResponsableTableViewCell {
            cell.getMyReports()
        }
        changeEnterprise(direction: .down)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
        Whisper.hide(whisperFrom: self.navigationController!)
    }
    
    func newState(state: ReportState) {
        self.view.isUserInteractionEnabled = true
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: self.weekSelected )) as? ResponsableTableViewCell else {
            return
        }
        switch state.reports {
        case .loading:
            self.view.isUserInteractionEnabled = false
            cell.loadingView.start()
            return
            
        case .Finished(let tupla as (Report,Murmur)):
            Whisper.show(whistle: tupla.1, action: .show(2.5))
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
 
 extension AllPendingsTableViewController:  EnterpriseProtocol {
    
    func showScrollOptions(sender: UISwipeGestureRecognizer) {
        changeEnterprise(direction: sender.direction == .right ? .left : .right)
    }
    
    @objc func tapRight() {
        changeEnterprise(direction: .right)
    }
    @objc func tapLeft() {
        changeEnterprise(direction: .left)
    }
    
    func changeEnterprise(direction: UISwipeGestureRecognizerDirection) {
        var animation: UITableViewRowAnimation = .none
        var animationStr = ""
        if direction == .left {
            animation = .right
            animationStr = "right"
            self.enterpriseSelected  -= enterpriseSelected > 0 ?  1 : 0
        }else if direction == .right{
            animation = .left
            animationStr = "left"
            self.enterpriseSelected += enterpriseSelected < pendings.count-1 ? 1 : 0
        }
        
        if animation != .none {
            didMove(toParentViewController: self)
            
            
            AnimatableReload.reload(tableView: self.tableView!, animationDirection: animationStr)
            //            self.tableView.reloadSections(IndexSet(integer: weekSelected), with: animation)
            
            
        }
    }
    @objc func selectEnterprise() {
        if pendings.count >  1 {
            self.pushToView(view: .enterprises)
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
                    if let e = pendings.first(where: {$0.enterprise.id == report.eid})?.enterprise {
                        vc.enterprise = e
                        vc.user = e.users.count > 0 ? e.users.first(where: {$0.id == report.uid}) : store.state.userState.user
                    }
                }
            }
        }
    }
 }
 extension AllPendingsTableViewController: weekProtocol {
    func changeWeek(direction : UISwipeGestureRecognizerDirection){
        
        if direction == .right {
            self.weekSelected += 1
        }else{
            self.weekSelected -= 1
            
        }
        if weekSelected > pendings[enterpriseSelected].weeks.count-1 {
            weekSelected = 0
            if enterpriseSelected < pendings.count-1{
                changeEnterprise(direction: .right)
            }
            return
        }else if weekSelected < 0{
            weekSelected = 0
            if enterpriseSelected > 0 {
                changeEnterprise(direction: .left)
            }
            return
        }
        let indexpath = IndexPath(row: 0, section: weekSelected)
        self.tableView.scrollToRow(at: indexpath, at: .top, animated: true)
        
    }
    @objc func tapLeftWeek() {
        changeWeek(direction: .left)
    }
    
    @objc func tapRightWeek() {
        changeWeek(direction: .right)
    }
    
    @objc func selectWeek() {
        self.pushToView(view: .weeksView)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        self.navigationItem.titleView = nil
        if parent != nil && self.navigationItem.titleView == nil {
            self.navigationItem.titleView = titleNavBarView(title: "Empresa", subtitle: self.pendings[enterpriseSelected].enterprise.name!)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.selectEnterprise))
            self.navigationItem.titleView?.addGestureRecognizer(tap)
            self.navigationItem.titleView?.isUserInteractionEnabled = true
        }
    }
 }
