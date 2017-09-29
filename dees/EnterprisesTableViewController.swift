//
//  EnterprisesTableViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 19/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
class EnterprisesTableViewController: UITableViewController {
    var user: User!
    var type = 1
    var enterprises = [Business]()
    var filtered = [Business]()
    let searchController = UISearchController(searchResultsController: nil)
    var searchFooter: SearchFooter!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchFooter = SearchFooter(frame: CGRect(x: 0, y: self.view.frame.height - 44, width: self.view.frame.width, height: 44))
        self.styleNavBarAndTab_1()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : Any]
        self.navigationItem.title = "Empresas"
        tableView.tableFooterView = UIView(frame: .zero)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView = searchFooter
        self.view.addSubview(searchFooter)
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let e : Business!
        
        if isFiltering() {
            e = filtered[indexPath.row]
        } else {
            e = enterprises[indexPath.row]
        }
        
        cell.textLabel?.text = e.name
        
        let border = UIView()
        border.frame = CGRect(x: 0, y: 42, width: Int(self.view.frame.width), height: 2)
        border.backgroundColor = UIColor(hexString: "#\(e.color! )ff")
        cell.addSubview(border)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
            if let vc =  navController.viewControllers[navController.viewControllers.count - 2] as? EnterpriseProtocol {
                if isFiltering() {
                    let eid = filtered[indexPath.row].id
                    if let index = enterprises.index(where: {$0.id == eid}) {
                        vc.enterpriseSelected = index
                    }
                }else{
                    vc.enterpriseSelected = indexPath.row
                }
                
                self.navigationController?.popViewController(animated: true)
            }
            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            searchFooter.setIsFilteringToShow(filteredItemCount: filtered.count, of: enterprises.count)
            return filtered.count
        }
        
        searchFooter.setNotFiltering()
        return enterprises.count
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return searchFooter
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

}
extension EnterprisesTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = BusinessState
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self) {
            $0.select({s in s.businessState})
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    func newState(state: BusinessState) {
        self.user = store.state.userState.user
        self.enterprises = state.business.count > 0 ? state.business.first(where: {$0.id == type})?.business ?? [] : store.state.userState.user.bussiness
        
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
        
        tableView.reloadData()
    }
    
}
extension EnterprisesTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
        filterContentForSearchText(searchController.searchBar.text!)
    }
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filtered = enterprises.filter({( e : Business) -> Bool in
            return (e.name?.lowercased().contains(searchText.lowercased()))!
        })
        
        tableView.reloadData()
    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}
