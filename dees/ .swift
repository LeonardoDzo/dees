//
//  UsersTableViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 16/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import SwipeCellKit

class UsersTableViewController: UITableViewController {
    var enterprise: Business!
    var users = [User]()
    var isSwipeRightEnabled = true
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .backgroundColor
    var defaultOptions = SwipeTableOptions()
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
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
extension UsersTableViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = UserState
    override func viewWillAppear(_ animated: Bool) {
        store.dispatch(GetUserAction(uid: -1))
        store.subscribe(self) {
            state in
            state.userState
        }
    }
    
    func newState(state: UserState) {
        switch state.status {
        case .loading:
            break
        default:
            users = state.users.filter({ u in
                return !enterprise.users.contains(where: {$0.id == u.id})
            })
            tableView.reloadData()
            break
        }
    }
}
extension UsersTableViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let u = users[indexPath.row]
        
        if orientation == .left {
            guard isSwipeRightEnabled else { return nil }
            
            let read = SwipeAction(style: .default, title: nil) { action, indexPath in
                //Set user for enterprise
                store.dispatch(AddUserBusinessAction(uid: u.id!, bid: self.enterprise.id))
            }
            
            read.hidesWhenSelected = true
            read.accessibilityLabel = "Agregarlo"
            
            
            return [read]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.transitionStyle = defaultOptions.transitionStyle
        
        switch buttonStyle {
        case .backgroundColor:
            options.buttonSpacing = 11
        case .circular:
            options.buttonSpacing = 4
            options.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
        }
        
        return options
    }

}
enum ButtonDisplayMode {
    case titleAndImage, titleOnly, imageOnly
}

enum ButtonStyle {
    case backgroundColor, circular
}
