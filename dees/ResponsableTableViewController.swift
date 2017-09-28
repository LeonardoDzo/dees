//
//  ResponsableTableViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 24/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Whisper

class ResponsableTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    var business: Business!
    var week: Week!
    override func viewDidLoad() {
        super.viewDidLoad()
        if store.state.userState.user.permissions.contains(where: {$0.rid.rawValue >= 602}) {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addUser))
            self.navigationItem.rightBarButtonItem = addButton
        }
        self.hideKeyboardWhenTappedAround()
        tableView.tableFooterView = UIView(frame: .zero)
        setupBack()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return business.users.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = business.users[indexPath.item]
        if store.state.userState.user.permissions.contains(where: {$0.rid.rawValue >= 602}) || store.state.userState.user.id == user.id {
            self.performSegue(withIdentifier: "reportSegue", sender: user)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let user = business.users[indexPath.item]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let u = business.users[indexPath.row]
            if store.state.userState.user.permissions.contains(where: {$0.rid.rawValue >= 602})  {
                deleteUser(u,indexPath: indexPath)
            }
        }
    }
    
    func deleteUser(_ u: User, indexPath: IndexPath){
        let alertView = UIAlertController(title: "\(business.name!)", message: "Desea sacar a: \(u.name!) de la empresa?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Eliminar", style: .destructive, handler: { (alert) in
            store.dispatch(baction.DeleteUser(uid: u.id!, bid: self.business.id))
            
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        alertView.addAction(action)
        alertView.addAction(cancelAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func addUser() -> Void {
        self.performSegue(withIdentifier: "usersSegue", sender: business)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reportSegue" {
           
        }else if segue.identifier == "usersSegue" {
            let vc = segue.destination as! UsersTableViewController
            vc.enterprise = sender as! Business
        }
    }
    
}
extension ResponsableTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.titleView = titleNavBarView(title: business.name!, subtitle:  (Date(string:week.startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:week.endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!)
        store.subscribe(self) {
            state in
            state
        }
        store.dispatch(baction.Get(id: business.id))
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
        Whisper.hide(whisperFrom: navigationController!)
    }
    
    func newState(state: AppState) {
        
        
        switch state.businessState.status {
        case .loading:
            break
        case .finished:
            Whisper.show(whisper: messages.succesG, to: navigationController!, action: .present)
            break
        case .failed:
            Whisper.show(whisper: messages.errorG, to: navigationController!, action: .present)
            break
        default:
            state.businessState.business.enumerated().forEach({
                index, b in
                if b.id == business?.id {
                    business = store.state.businessState.business[index]
                    return
                }else{
                    b.business.enumerated().forEach({
                        i2, b2 in
                        if b2.id == business?.id {
                            business = store.state.businessState.business[index].business[i2]
                            return
                        }
                    })
                }
            })
            tableView?.reloadData()
            break
        }
        
    }
}
