//
//  UsersTableViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 17/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Whisper
import SwipeCellKit
class UsersTableViewController: UITableViewController {
    var users = [User]()
    var enterprise : Business!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UIView().setTitle(title: "Usuarios", subtitle: "")
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
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SwipeTableViewCell
        let u = users[indexPath.row]
        cell.delegate = self
        cell.textLabel?.text = u.name
        cell.detailTextLabel?.text = u.email
        return cell
    }

}
extension UsersTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    override func viewWillAppear(_ animated: Bool) {
        store.dispatch( UsersAction.get(uid: -1) )
        
        store.subscribe(self) {
            state in
            state
        }
    
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
                if b.id == enterprise?.id {
                    enterprise = store.state.businessState.business[index]
                    return
                }else{
                    b.business.enumerated().forEach({
                        i2, b2 in
                        if b2.id == enterprise?.id {
                            enterprise = store.state.businessState.business[index].business[i2]
                            return
                        }
                    })
                }
            })
            users = state.userState.users.filter({u in
                return !enterprise.users.contains(where: {$0.id == u.id})
            })
            tableView.reloadData()
            break
        }
        
    }
}

extension UsersTableViewController : SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .left else { return nil }
        let u = users[indexPath.row]
        let addAction = SwipeAction(style: .default, title: "Agregar") { action, indexPath in
            store.dispatch(baction.AddUser(uid: u.id!, bid: self.enterprise.id))
        }
        return [addAction]
    }

}
