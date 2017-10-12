//
//  LibraryViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 11/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {
    var weeks: [Week] = []
    var weekSelected = 0
    var enterpriseSelected = 0
    var enterprises: [Business] = []
    lazy var weeksTitleView : weeksView? = weeksView(frame: .zero)
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.formatView()
        self.styleNavBarAndTab_1()
        weeks = store.state.weekState.getWeeks()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.selectEnterprise))
        enterpriseStack.addGestureRecognizer(tap)
        enterpriseStack.isUserInteractionEnabled = true
        self.enterprises = store.state.businessState.business.count > 0 ? store.state.businessState.business.first(where: {$0.id == 0})?.business ?? [] : store.state.userState.user.bussiness
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
        // Do any additional setup after loading the view.
    }


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var enterpriseLbl: UILabel!
    @IBOutlet weak var enterpriseStack: UIStackView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        changeEnterprise(direction: .down)
    }

}
extension LibraryViewController: weekProtocol {

    func changeWeek(direction: UISwipeGestureRecognizerDirection) {
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
        }
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
    
    func tapLeftWeek() {
        changeWeek(direction: .left)
    }
    
    func tapRightWeek() {
        changeWeek(direction: .right)
    }
    
    @objc func selectWeek() {
        self.pushToView(view: .weeksView)
    }
}
extension LibraryViewController: EnterpriseProtocol {
    
    
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
        
        self.enterpriseStack.alpha = 0.0
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseIn, animations: {
            self.enterpriseStack.alpha = 1.0
            self.enterpriseLbl.text = self.enterprises[self.enterpriseSelected].name
        }, completion: nil)
        
    }
    
    func selectEnterprise() {
        if enterprises.count >  1 {
            self.pushToView(view: .enterprises, sender: 0)
        }
    }
    
    
}
