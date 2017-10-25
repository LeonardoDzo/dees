//
//  LibraryViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 11/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Whisper

class LibraryViewController: UIViewController {
    var weeks: [Week] = []
    var weekSelected = 0
    var enterpriseSelected = 0
    var enterprises: [Business] = []
    var files = [File]()
    lazy var weeksTitleView : weeksView? = weeksView(frame: .zero)
    
    @IBOutlet weak var typeSelected: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var enterpriseLbl: UILabel!
    @IBOutlet weak var enterpriseStack: UIStackView!
    @IBOutlet weak var border: NSLayoutConstraint!
    @IBOutlet weak var borderLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.formatView()
        self.styleNavBarAndTab_1()
        weeks = store.state.weekState.getWeeks()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.selectEnterprise))
        enterpriseStack.addGestureRecognizer(tap)
        enterpriseStack.isUserInteractionEnabled = true
        tableView.tableFooterView = UIView()
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
         self.enterprises = store.state.businessState.business.count > 0 ? store.state.businessState.business.first(where: {$0.id == store.state.userState.type})?.business ?? [] : store.state.userState.user.bussiness
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
        
        store.subscribe(self) {
            subcription in
            subcription.select({ (state) in
                state.files
            })
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        changeEnterprise(direction: .down)
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    @IBAction func handleChangeType(_ sender: UISegmentedControl) {
        files = store.state.files.get()
        changeType()
    }
    func changeType() -> Void {
        if  typeSelected.selectedSegmentIndex == 0 {
            files = files.filter({!$0.isImage()})
        }else{
            files = files.filter({$0.isImage()})
        }
        if !store.state.userState.user.permissions.contains(where: {$0.rid.rawValue > 601 }) {
            files = files.filter({ (file) -> Bool in
                guard let uid = file.uid else{
                    return false
                }
                if store.state.userState.user.id == uid {
                    return true
                }
                return false
            })
        }
        if files.count == 0 {
             let imageView = UIImageView(image: #imageLiteral(resourceName: "emptyback"))
            self.tableView.backgroundView = imageView
            
        }else{
            self.tableView.backgroundView = nil
        }
        self.tableView.backgroundColor = #colorLiteral(red: 0.9589598775, green: 0.9689574838, blue: 0.9729653001, alpha: 1)
        tableView.reloadSections(IndexSet(integer: 0), with: .fade)
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
            store.dispatch(FileActions.get(eid: enterprises[self.enterpriseSelected].id, wid: weeks[self.weekSelected].id))
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
        self.borderLbl.alpha = 0.0
        let e = self.enterprises[self.enterpriseSelected]
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseIn, animations: {
            self.enterpriseStack.alpha = 1.0
            self.borderLbl.alpha = 1.0
            self.borderLbl.backgroundColor =  UIColor(hexString: "#\(e.color!)ff")
            self.enterpriseLbl.text = e.name
        }, completion: nil)
        store.dispatch(FileActions.get(eid: e.id))
    }
    
    func selectEnterprise() {
        if enterprises.count >  1 {
            self.pushToView(view: .enterprises, sender: 0)
        }
    }
    
}
extension LibraryViewController : StoreSubscriber {
    
    typealias StoreSubscriberStateType = FileState
    
    func newState(state: FileState) {
        switch state.files {
        case .loading:
            
            break
        case .Finished(let tupla as ([File], Murmur)):
            files = tupla.0
            Whisper.show(whistle: tupla.1, action: .show(3.0))
            changeType()
        default:
            break
        }
    }
}
extension LibraryViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Filter for type
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let file = files[indexPath.row]
        cell.textLabel?.text = file.name
        cell.imageView?.image = file.getImage()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.pushToView(view: .webView, sender: (files[indexPath.row], enterprises[self.enterpriseSelected].id))
    }
    
    
}
