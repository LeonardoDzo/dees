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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        tableView.tableFooterView = UIView(frame: .zero)
        setupBack()
    }
    override func viewWillAppear(_ animated: Bool) {
       group = realm.realm.objects(Group.self).filter("companyId = %@ AND type = %@", conf.eid, conf.type).toArray(ofType: Group.self)
        print("Grupos: ", group)
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
        return group.count
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = group[indexPath.row]._party.first(where: {$0.id != store.state.userState.user.id}) {
            conf.uid = user.id
            self.pushToView(view: .chatView, sender: conf)
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let user = group[indexPath.row]._party.first(where: {$0.id != store.state.userState.user.id}) {
            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = user.email
        }
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
}
