//
//  WeekSelectionViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
protocol Segue: class {
    func selected(_ segue: String, sender: Any?) -> Void
}
class WeekSelectionViewController: UITableViewController, Segue, UIGestureRecognizerDelegate {
    var week: Week!
    var user: User!
    var enterprises = [Business]()
    var type: Int!
    var cellSelected = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.tableView?.addGestureRecognizer(lpgr)
        
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Jale para actualizar")
        self.refreshControl?.addTarget(self, action:#selector(refresh(sender:)), for: UIControlEvents.valueChanged)
       
    }
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        store.dispatch(GetBusinessAction())
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let p = gestureReconizer.location(in: self.tableView)
        let indexPath = self.tableView?.indexPathForRow(at: p)
        
        if let index = indexPath {
            if index.row % 2 == 0 {
                let e = enterprises[index.row/2]
                self.performSegue(withIdentifier: "enterpriseSegue", sender: e)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selected(_ segue: String, sender: Any?) {
        if segue.isEmpty {
            add(sender as! Business)
            return
        }
        self.performSegue(withIdentifier: segue, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "responsableSegue" {
            let vc = segue.destination as! ReponsableCollectionViewController
            vc.business = sender as! Business
            vc.week = week
        }else if segue.identifier == "enterpriseSegue" {
            let vc = segue.destination as! EnterpriseViewViewController
            vc.enterprise = sender as! Business
        }
    }
    func add(_ enterpriseFather: Business) -> Void {
        let alertController = UIAlertController(title: "Cambiar Nombre", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            var e = Business()
            e.color = enterpriseFather.color
            e.type = enterpriseFather.type
            e.ext = enterpriseFather.id
            guard let name = firstTextField.text, !name.isEmpty, (firstTextField.text?.characters.count)! > 4 else {
                
                return
            }
            e.name = name
            store.dispatch(CreateBusinessAction(e: e))
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Cual es el nombre"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
extension WeekSelectionViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enterprises.count*2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BusinessTableViewCell
            let e = enterprises[Int(indexPath.row/2)]
            
            cell.arrowImg.isHidden = false
            cell.accessoryType = .none
            if cellSelected - 1 != indexPath.row {
                cell.arrowImg.image = #imageLiteral(resourceName: "expand")
            }else{
                cell.arrowImg.image = #imageLiteral(resourceName: "collapse")
            }
            
            cell.title.text = "\(e.name!)"
            
            if e.color != nil {
                cell.colorLbl.backgroundColor = UIColor(hexString: "#\(e.color!)ff")
            }
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! ChildTableViewCell
        let e = enterprises[(indexPath.row-1)/2]
        
        cell.data = e
        cell.segueDelegate = self
        cell.tableView.reloadData()
        cell.chageHeight()
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return 60.0
        }else{
            if indexPath.row == cellSelected {
                let e = enterprises[(indexPath.row-1)/2]
                let value = e.business.count + 1
                let heigtht = value * 44
                return CGFloat(heigtht)
            }
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        if indexPath.row == cellSelected - 1 {
            let e = enterprises[indexPath.row/2]
            self.performSegue(withIdentifier: "responsableSegue", sender: e)
            return
        }else{
            if cellSelected != -1 {
                tableView.reloadData()
            }
            cellSelected = indexPath.row + 1
        }
        tableView.reloadRows(at: [indexPath,], with: .automatic)
        
        
    }
}
extension WeekSelectionViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = BusinessState
    
    override func viewWillAppear(_ animated: Bool) {
        setTitle()
        if type == nil {
            type = store.state.userState.type
        }else{
            store.state.userState.type = type
        }
        store.subscribe(self){
            state in
            state.businessState
        }
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.back))
        
        if self.tabBarController?.selectedIndex == 0 && user.rol == .Superior {
            self.navigationItem.leftBarButtonItem = back
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    func newState(state: BusinessState) {
        self.user = store.state.userState.user
        
        self.enterprises = user.rol == .Superior ? state.business.filter({$0.type == type}) : state.business.filter({b in
            return user.bussiness.contains(where: {ub in
                return b.id == ub.id || b.business.contains(where: {$0.id == ub.id})
            })
        })
        
        setTitle()
        self.tableView.reloadData()
    }
    
    func setTitle(){
        
        if week == nil {
            week = store.state.reportState.weeks.first
        }else{
            
            self.navigationItem.titleView = UIView().setTitle(title: "Semana:", subtitle:  (Date(string:week.startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:week.endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!)
        }
        
    }
}
