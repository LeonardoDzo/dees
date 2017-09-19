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
    var section = 0
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
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        self.navigationItem.titleView = nil
        if parent != nil && self.navigationItem.titleView == nil {
            let xview = self.view.setWeeks(title: "Reporte", subtitle:  (Date(string:self.weeks[self.weekSelected].startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:self.weeks[self.weekSelected].endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!, controller: self)
            self.navigationItem.titleView = xview
            self.navigationItem.titleView?.isUserInteractionEnabled = true
            xview.isUserInteractionEnabled = true
        }
    }
    
    func showScrollOptions(sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            section -= section > 0 ? 1 : 0
        }else{
            section += section < enterprises.count-1 ? 1 : 0
        }
        goTo()
    }
    
    func tapRigth() {
        section += section < enterprises.count-1 ? 1 : 0
        goTo()
    }
    func tapLeft() {
        section -= section > 0 ? 1 : 0
        goTo()
    }
    
    func goTo() -> Void {
        let indexpath = IndexPath(row: 0, section: section)
        self.tableView.scrollToRow(at: indexpath, at: .top, animated: true)
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
    
    func selectBusiness() -> Void {
        let alert = UIAlertController(title: "Selecciona la empresa", message: nil, preferredStyle: .actionSheet)
        self.enterprises.enumerated().forEach({
            i,b in
            let actionAlert = UIAlertAction(title: b.name, style: .default, handler: { _ in
                self.section = i
                self.goTo()
            })
            alert.addAction(actionAlert)
        })
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if section != Bsection {
            Bsection = section
            store.dispatch(ReportsAction.Get(eid: self.enterprises[indexPath.section].id, wid: self.weeks[weekSelected].id))
        }
    }
    
    func rotated() -> Void {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 575
    }
    
}
extension AllReportsTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = BusinessState
    
    override func viewWillAppear(_ animated: Bool) {
       
        if type == nil {
            type = store.state.userState.type
        }else{
            store.state.userState.type = type
        }
        self.weeks = store.state.reportState.weeks
        
        store.subscribe(self){
            $0.select({
                s in s.businessState
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    func newState(state: BusinessState) {
        self.user = store.state.userState.user
        enterprises.removeAll()
        
        
        
        self.enterprises = user.rol == .Superior ? state.business.filter({$0.type == type}) : state.business.filter({b in
            return user.bussiness.contains(where: {ub in
                return b.id == ub.id || b.business.contains(where: {$0.id == ub.id})
            })
        })
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
        
        tableView.reloadData()
    }
    
}

extension AllReportsTableViewController : weekProtocol {
    func changeWeek(direction : UISwipeGestureRecognizerDirection){
        if direction == .right {
            self.weekSelected  -= weekSelected > 0 ?  1 : 0
        }else{
            self.weekSelected += weekSelected < weeks.count-1 ? 1 : 0
        }
        didMove(toParentViewController: self)
        self.tableView.reloadData()
    }
    func tapLeftWeek() {
        changeWeek(direction: .left)
    }
    func tapRightWeek() {
        changeWeek(direction: .right)
    }
    func selectWeek() {
        let alert = UIAlertController(title: "Selecciona la semana", message: nil, preferredStyle: .actionSheet)
        self.weeks.enumerated().forEach({
            i,b in
            let actionAlert = UIAlertAction(title: (Date(string:self.weeks[i].startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:self.weeks[i].endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!, style: .default, handler: { _ in
                self.weekSelected = i
                self.tableView.reloadData()
                self.didMove(toParentViewController: self)
            })
            alert.addAction(actionAlert)
        })
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)

    }
}
