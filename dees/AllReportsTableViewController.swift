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
import AnimatableReload
import KDLoadingView
protocol GoToProtocol :  class {
    func goTo(_ route: RoutingDestination, sender: Any?)
    func viewInfo(_ report: Report,_ type: String) -> Void
}

class AllReportsTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    var isFocus = false
    var enterprises = [Business]()
    var type : Int!
    var user: User!
    var enterpriseSelected = 0
    var Bsection = -1
    var weeks = [Week]()
    var weekSelected: Int = 0
    lazy var weeksTitleView : weeksView? = weeksView(frame: .zero)
    let notificationCenter = NotificationCenter.default
    var lastContentOffset: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConf()
        setupNavBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var vc = sb.instantiateViewController(withIdentifier: "AllReportsTableViewController") as? AllReportsTableViewController
        if vc != nil {
            vc = nil
            
            URLCache.shared.removeAllCachedResponses()
        }
    }
    
    
    
    
    deinit {
        print("deinit")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return enterprises.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number @objc of rows
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResponsableTableViewCell
        cell.enterprise = enterprises[indexPath.section]
        cell.tag = self.weeks[self.weekSelected].id
        cell.gotoProtocol = self
        cell.changeEnterpriseProtocol = self
        
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
        if e.color != nil {
             cell.borderColor.layer.backgroundColor = UIColor(hexString: "#\(e.color!)##")?.cgColor
        }
       
        cell.setTitle(name!)
        return cell
    }
    
    @objc func rotated() -> Void {
        // self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ResponsableTableViewCell {
            if cell.users.count > 0 {
                cell.lastsection = 0
                cell.tableView.scrollToRow(at: IndexPath(row: 0, section: cell.lastsection), at: .top, animated: false)
                cell.tag = self.weeks[self.weekSelected].id
                cell.enterprise = self.enterprises[self.enterpriseSelected]
                cell.tableView.reloadData()
                cell.getMyReports()
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
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let indexPath = tableView.indexPathForRow(at: visiblePoint){
            if let cell = tableView.cellForRow(at: indexPath) as? ResponsableTableViewCell {
                cell.tag = self.weeks[self.weekSelected].id
                cell.enterprise = self.enterprises[self.enterpriseSelected]
                cell.tableView.reloadData()
                cell.getMyReports()
            }
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
        if let cell = tableView.cellForRow(at: IndexPath(row: 0,section: self.enterpriseSelected)) as? ResponsableTableViewCell {
            cell.getMyReports()
        }
        changeEnterprise(direction: .down)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
        if let cell = tableView.cellForRow(at: IndexPath(row: 0,section: self.enterpriseSelected)) as? ResponsableTableViewCell {
            cell.notificationToken?.invalidate()
        }
        Whisper.hide(whisperFrom: self.navigationController!)
    }
    
    func newState(state: ReportState) {
        self.view.isUserInteractionEnabled = true
        
       
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: self.enterpriseSelected )) as? ResponsableTableViewCell else {
            return
        }
        cell.loading.stopAnimating()
        cell.loading.hidesWhenStopped = true
        cell.notificationToken?.invalidate()
        switch state.reports {
        case .loading:
            self.view.isUserInteractionEnabled = false
            cell.loading.startAnimating()
            cell.loading.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            return
            
        case .Finished(let tupla as (Report,Murmur)):
            //Loader.removeLoaderFromTableView(table: cell.tableView)
            Whisper.show(whistle: tupla.1, action: .show(2.5))
            cell.updated()
            cell.checkGroup()
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
        let focusBtn = UIBarButtonItem(image: !isFocus ? #imageLiteral(resourceName: "myReports") : #imageLiteral(resourceName: "allReports"), style: .plain, target: self, action: #selector(self.getFocusOnMyEnterprises))
        self.navigationItem.rightBarButtonItems = [add,focusBtn]
    }
    
    
    
    @objc func updateReport() -> Void {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: self.enterpriseSelected )) as? ResponsableTableViewCell {
            cell.update()
        }
    }
    
    func setVars() -> Void {
        self.user = store.state.userState.user
        getEnterprise()
        self.weeks = store.state.weekState.getWeeks()
        
        didMove(toParentViewController: self)
    }
    @objc func getFocusOnMyEnterprises(){
        self.enterpriseSelected = 0
        self.isFocus =  !self.isFocus
        if !isFocus {
            self.enterprises.removeAll()
        }
        getEnterprise()
        setupNavBar()
    }
    func getEnterprise() -> Void {
        if isFocus {
            self.enterprises = self.enterprises.filter({$0.users.contains(where: { $0.id == store.state.userState.user.id!})})
            
        }else {
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
        }
        self.tableView.reloadData()
        
        
    }
}

extension AllReportsTableViewController : weekProtocol {
    func changeWeek(direction : UISwipeGestureRecognizerDirection){
        var animation: UITableViewRowAnimation = .none
        var animationStr: String!
        if direction == .right {
            if weekSelected > 0 {
                animation = .left
                animationStr = "left"
                self.weekSelected -= 1
            }
        }else{
            if weekSelected < weeks.count-1 {
                animation = .right
                animationStr = "right"
                self.weekSelected += 1
            }
        }
        
        if animation != .none {
            didMove(toParentViewController: self)
           
            AnimatableReload.reload(tableView: self.tableView!, animationDirection: animationStr)
        }
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
            weeksTitleView = weeksView(ctrl: self)
            if weeks.count > 0 {
                weeksTitleView?.setTitle(title: "Reporte", subtitle: self.weeks[self.weekSelected].getTitleOfWeek())
            }
            
            self.navigationItem.titleView = weeksTitleView
            
            self.navigationItem.titleView?.isUserInteractionEnabled = true
        }
    }
}

extension AllReportsTableViewController : EnterpriseProtocol {
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
        if direction == .left {
            self.enterpriseSelected  -= enterpriseSelected > 0 ?  1 : 0
        }else if direction == .right{
            self.enterpriseSelected += enterpriseSelected < enterprises.count-1 ? 1 : 0
        }
        let indexpath = IndexPath(row: 0, section: enterpriseSelected)
        self.lastContentOffset = CGFloat( self.enterpriseSelected * Int(self.tableView.rowHeight))
        self.tableView.scrollToRow(at: indexpath, at: .top, animated: true)
        
    }
    @objc func selectEnterprise() {
        if enterprises.count >  1 {
            self.pushToView(view: .enterprises, sender: isFocus)
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
        var route = route
        guard var conf = sender as? configuration else {
            return
        }
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: self.enterpriseSelected)) as? ResponsableTableViewCell {
            conf.user = cell.getUser()
        }
        if route == .chatView, store.state.userState.user.id  == conf.uid {
            let group = realm.realm.objects(Group.self).filter("companyId = %@ AND type = %@", conf.eid, conf.type).toArray(ofType: Group.self)
            
            if group.count > 1 {
               route = .chatResponsables
            }
        }

        self.pushToView(view: route, sender: conf)
    }
    func viewInfo(_ report: Report,_ type: String) {
        let data = [
            "report": report,
            "type": type
            ] as [String : Any]
        self.performSegue(withIdentifier: "viewInfo", sender: data)
    }
}
