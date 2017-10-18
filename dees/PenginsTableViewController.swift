//
//  PenginsTableViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 17/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Whisper

struct modelWeek {
    var week : Week!
    var users : [Int]
}
struct modelUser {
    var user : User!
    var weeks : [Week]
}


/// Reportes no creados organizados por empleados
struct pendingModel{
    var enterprise: Business!
    var users: [modelUser]
}


class PenginsTableViewController: UITableViewController {
    let nib = UINib(nibName: "TitleView", bundle: nil)
    let user = store.state.userState.user
    let weeks = store.state.weekState.getWeeks()
    var enterprises  = [Business]()
    var sections = [("Pendientes", [pendingModel](), false),("Otros", [pendingModel](), false)]
    var pendings = [pendingModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.styleNavBarAndTab_1()
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "TitleHeaderCell")
        self.tableView.tableFooterView = UIView()
        store.dispatch(PendingsActions.get(eid: store.state.userState.type))
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sections[section].1.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if sections[indexPath.section].2 {
            if indexPath.section == 1 && indexPath.row % 2 != 0 {
                let p = sections[indexPath.section].1[indexPath.row]
                var count = 0
                p.users.forEach({ (u) in
                    count += u.weeks.count
                })
                return  CGFloat(count * 30) 
            }
            return 44
        }else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let p = sections[indexPath.section].1[indexPath.row]
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            var maxV = 0
            p.users.forEach { (m) in
                maxV = max(maxV, m.weeks.count)
            }
            cell.textLabel?.text = p.enterprise.name! + " (\(maxV))"
            return cell
        }
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellName", for: indexPath)
            cell.textLabel?.text = p.enterprise.name!
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! ResponsablePendingTableViewCell
        cell.model = p
        cell.tableView.reloadData()
        return cell
        
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderView()
        header.customInit(title: sections[section].0, section: section, delegate: self)
        
        return header
    }

}
extension PenginsTableViewController: ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        sections[section].2 = !sections[section].2
        tableView.beginUpdates()
        for i in 0 ..< sections[section].1.count {
            if let cell = tableView.cellForRow(at: IndexPath(row: i, section: section)) as? ResponsablePendingTableViewCell {
                cell.model =  sections[section].1[i]
                tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
            }
            
            
        }
        tableView.endUpdates()
    }
    
    
}
extension PenginsTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = PendingsState
    
    func newState(state: PendingsState) {
        switch state.pendings {
        case .loading:
            break
        case .Failed(let m as Murmur):
            Whisper.show(whistle: m, action: .show(3.0))
            let background = UIImageView()
            tableView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            background.image = #imageLiteral(resourceName: "generic-error_shot")
            background.contentMode = .scaleAspectFit
            tableView.backgroundView = background
            return
        case .Finished(let tupla as ([Pending], [Pending])):
            sections[0].1 = createModels(pendings: tupla.0)
            sections[1].1 = createModels(pendings: tupla.1)
            self.tableView.reloadData()
            return
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self){
            $0.select({ (s)  in
                s.pendingState
            })
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }

    
    func createModels(pendings: [Pending]) -> [pendingModel] {
        var filtered = [pendingModel]()
        self.enterprises.forEach({ b in
            let filter : [Pending] = pendings.filter({$0.eid == b.id})
            if filter.count > 0 {
                var model = pendingModel(enterprise: b, users: [])
                filter.forEach({p in
                    let mW = modelUser(user: b.users.first(where: {$0.id == p.uid}), weeks: [weeks.first(where: {$0.id == p.wid})!])
                    if let index = model.users.index(where: {$0.user.id == p.uid}) {
                        model.users[index].weeks.append(weeks.first(where: {$0.id == p.wid})!)
                    }else{
                        model.users.append(mW)
                    }
                })
                filtered.append(model)
            }
        })
        return filtered
    }
    
}
