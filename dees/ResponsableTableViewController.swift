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
    var group = [Group]()
    var conf : configuration!
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        tableView.tableFooterView = UIView(frame: .zero)
          let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapPress(gestureReconizer:)))
        self.tableView.addGestureRecognizer(tapGesture)
        setupBack()
    }
    override func viewWillAppear(_ animated: Bool) {
       group = realm.realm.objects(Group.self).filter("companyId = %@ AND type = %@", conf.eid, conf.type.rawValue).toArray(ofType: Group.self)
        if group.count == 0 {
            store.subscribe(self) {
                $0.select({ (s)  in
                    s.userState
                })
            }
            store.dispatch(UsersAction.get(eid: conf.eid))
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    @objc func handleTapPress(gestureReconizer: UITapGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let p = gestureReconizer.location(in: self.tableView)
        if let indexPath = self.tableView?.indexPathForRow(at: p) {
            if group.count == 0 {
                let user = users[indexPath.row]
                conf.uid = user.id
                self.pushToView(view: .chatView, sender: conf)
                
            }else{
                if let user = group[indexPath.row]._party.first(where: {$0.id != store.state.userState.user.id}) {
                    conf.uid = user.id
                    self.pushToView(view: .chatView, sender: conf)
                }
            }
        }
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return group.count == 0 ? self.users.count : group.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if group.count == 0 {
            let user = users[indexPath.row]
            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = user.email
            
        }else{
            if let user = group[indexPath.row]._party.first(where: {$0.id != store.state.userState.user.id}) {
                cell.textLabel?.text = user.name
                cell.detailTextLabel?.text = user.email
            }
        }
        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
}
extension ResponsableTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = UserState
    func newState(state: UserState) {
        self.users = state.users
        self.tableView.reloadData()
    }
}
