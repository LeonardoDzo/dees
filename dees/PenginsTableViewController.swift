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
import KDLoadingView
struct modelWeek {
    var week : Week!
    var users : [User]
}
struct modelUser {
    var user : User!
    var weeks : [Week]
}


/// Reportes no creados organizados por empleados
struct pendingModel{
    var enterprise: Business!
    var users: [modelUser]
    var weeks: [modelWeek]
    var toggle = false
}



class PenginsTableViewController: UITableViewController {
    let nib = UINib(nibName: "TitleView", bundle: nil)
    let user = store.state.userState.user
    let weeks = store.state.weekState.getWeeks()
    var enterprises  = [Business]()
    
    var unCreated = [pendingModel]()
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredPendings = [pendingModel]()
    var sections = [("Mis Pendientes", [pendingModel](), true),("Reportes no creados", [pendingModel](), false)]
    
    lazy var refCtrl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    lazy var loading: KDLoadingView = {
        let view = KDLoadingView(frame: CGRect(origin: CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2), size: CGSize(width: 100, height: 100)))
        view.firstColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        view.secondColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        view.hidesWhenStopped = true
        return view
    }()
    
    @objc func handleRefresh() {
        store.dispatch(PendingsActions.get(eid: store.state.userState.type))
        
    }

   
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
        self.setupBack()
        
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "TitleHeaderCell")
        self.tableView.tableFooterView = UIView()
        self.navigationItem.titleView = titleNavBarView(title: "Pendientes", subtitle: "")
       
        self.styleNavBarAndTab_1()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Buscar Empresas"
        searchController.searchBar.barStyle = .blackTranslucent
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        self.tableView.addSubview(self.refCtrl)
        
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
        if isFiltering() && section == 0 {
            return filteredPendings.count
        }
        if section == 0 {
            return sections[section].1.count
        }
        return sections[section].1.count * 2
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if sections[indexPath.section].2 {
            if indexPath.section == 1 && indexPath.row % 2 != 0 {
                
                let p = sections[indexPath.section].1[indexPath.row/2]
                if !p.toggle {
                    return 0
                }
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 && indexPath.row % 2 == 0  {
           let row = indexPath.row/2
            sections[indexPath.section].1[row].toggle = !sections[indexPath.section].1[row].toggle
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }else if indexPath.section == 0 {
            self.pushToView(view: .allPendings, sender: sections[indexPath.section].1)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let p = !isFiltering() ? sections[indexPath.section].1[indexPath.row] : filteredPendings[indexPath.row]
            var maxV = 0
            p.users.forEach { (m) in
                maxV = max(maxV, m.weeks.count)
            }
            cell.imageView?.image = #imageLiteral(resourceName: "company_default")
            cell.textLabel?.text = p.enterprise.name! + " (\(maxV))"
            return cell
        }
        let p = sections[indexPath.section].1[indexPath.row/2]
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellName", for: indexPath)
            cell.imageView?.image = #imageLiteral(resourceName: "company_default")
            cell.textLabel?.text = p.enterprise.name!
            tableView.separatorColor = UIColor(hexString: "#\(p.enterprise.color!)00")
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! ResponsablePendingTableViewCell
        cell.model = p
        cell.tableView.reloadData()
        return cell
        
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderView()
        
        header.layer.frame.origin.x = self.view.frame.width / 3
        header.customInit(title: sections[section].0, section: section, delegate: self)
        header.textLabel?.textAlignment = .center
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
        refCtrl.endRefreshing()
        loading.stopAnimating()

        switch state.pendings {
        case .loading:
            loading.isHidden = false
            loading.startAnimating()
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
        store.dispatch(PendingsActions.get(eid: store.state.userState.type))
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
                var model = pendingModel(enterprise: b, users: [], weeks: [], toggle: false)
                filter.forEach({p in
                    let mU = modelUser(user: b.users.first(where: {$0.id == p.uid}), weeks: [weeks.first(where: {$0.id == p.wid})!])
                    if let index = model.users.index(where: {$0.user.id == p.uid}) {
                        model.users[index].weeks.append(weeks.first(where: {$0.id == p.wid})!)
                    }else{
                        model.users.append(mU)
                    }
                    let user = b.users.first(where: {$0.id == p.uid})!
                    let mW = modelWeek(week: weeks.first(where: {$0.id == p.wid}), users: [user])
                    if let index = model.weeks.index(where: {$0.week.id == p.wid}) {
                        model.weeks[index].users.append(user)
                    }else{
                        model.weeks.append(mW)
                    }
                })
                filtered.append(model)
            }
        })
        return filtered
    }
    
}
extension PenginsTableViewController: UISearchResultsUpdating {
   
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "Todas") {
        filteredPendings = sections[0].1.filter({( p : pendingModel) -> Bool in
            return (p.enterprise.name?.lowercased().contains(searchText.lowercased()))!
        })
        
        tableView.reloadData()
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
