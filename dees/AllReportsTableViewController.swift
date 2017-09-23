//
//  AllReportsTableViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 11/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
class AllReportsTableViewController: UITableViewController {
    var enterprises = [Business]()
    var type : Int!
    var user: User!
    var enterpriseSelected = 0
    var Bsection = -1
    var weeks = [Week]()
    var weekSelected: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleNavBarAndTab_1()
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.showScrollOptions(sender:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.showScrollOptions(sender:)))
        swipeRight.direction = .right
        self.tableView.addGestureRecognizer(swipeLeft)
        self.tableView.addGestureRecognizer(swipeRight)
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
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
        cell.tableView.reloadData()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView().titleOfEnterprise(section: section, controller: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    }
    
    func rotated() -> Void {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 575
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        update(isFinished: false)
    }
    
}

extension AllReportsTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = ReportState
    
    override func viewWillAppear(_ animated: Bool) {
       
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
    }
    
    func newState(state: ReportState) {
        switch state.status {
        case .loading:
            break
        case .finished:
            update(isFinished: true)
            break
        case .failed:
            update(isFinished: false)
            break
        default:
            break
        }
    }
    
    func update(isFinished: Bool) -> Void {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: self.enterpriseSelected )) as? ResponsableTableViewCell {
            cell.avaible = isFinished
            cell.reports = store.state.reportState.reports.filter({$0.eid == self.enterprises[enterpriseSelected].id && $0.wid! == self.weeks[self.weekSelected].id})
            cell.tableView.reloadData()
        }
    }
    func setVars() -> Void {
        self.user = store.state.userState.user
        
        if enterprises.count == 0 {
            enterprises.removeAll()
            self.enterprises = user.rol == .Superior ? store.state.businessState.business.filter({$0.type == type}) : store.state.businessState.business.filter({b in
                return user.bussiness.contains(where: {ub in
                    return b.id == ub.id || b.business.contains(where: {$0.id == ub.id})
                })
            })
        }
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
        self.weeks = store.state.reportState.weeks
        didMove(toParentViewController: self)
        tableView.reloadData()
        update(isFinished: false)
        
    }
    
}

extension AllReportsTableViewController : weekProtocol {
    func changeWeek(direction : UISwipeGestureRecognizerDirection){
        let animation: UITableViewRowAnimation
        if direction == .right {
            animation = .left
            self.weekSelected  -= weekSelected > 0 ?  1 : 0
        }else{
            animation = .right
            self.weekSelected += weekSelected < weeks.count-1 ? 1 : 0
        }
        didMove(toParentViewController: self)
        self.tableView.reloadSections(IndexSet(integer: self.enterpriseSelected), with: weekSelected == 0 ? .none : weeks.count-1 == weekSelected ? .none :  animation)
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
           
            self.navigationItem.titleView = {
               let view =  weeksView(title: "Reporte", subtitle:  (Date(string:self.weeks[self.weekSelected].startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:self.weeks[self.weekSelected].endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!, controller: self)
                return view
            }()
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
        self.tableView.scrollToRow(at: indexpath, at: .top, animated: true)
       
    }
    func selectEnterprise() {
        self.pushToView(view: .enterprises)
    }
}
