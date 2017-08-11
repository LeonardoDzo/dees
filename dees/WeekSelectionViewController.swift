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
class WeekSelectionViewController: UITableViewController, Segue {
    var week: Week!
    var user: User!
    var enterprises = [Business]()
    

    var cellSelected = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.formatView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selected(_ segue: String, sender: Any?) {
        self.performSegue(withIdentifier: segue, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "responsableSegue" {
            let vc = segue.destination as! ReponsableCollectionViewController
            vc.business = sender as! Business
        }
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
            if (e.business?.count)! > 0 {
                cell.arrowImg.isHidden = false
                cell.accessoryType = .none
                if cellSelected - 1 != indexPath.row {
                    cell.arrowImg.image = #imageLiteral(resourceName: "expand")
                }else{
                    cell.arrowImg.image = #imageLiteral(resourceName: "collapse")
                }
            }else{
                cell.arrowImg.isHidden = true
                cell.accessoryType = .detailDisclosureButton
            }
            cell.title.text = "\(e.name!)"
           
            cell.colorLbl.backgroundColor = UIColor(hexString: "#\(e.color!)ff")
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
                let value = e.business?.count ?? 0
                let heigtht = value * 44
                return CGFloat(heigtht)
            }
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            let e = enterprises[indexPath.row/2]
            if (e.business?.count)! == 0{
                self.performSegue(withIdentifier: "responsableSegue", sender: e)
                return
            }
        }
        if indexPath.row == cellSelected - 1 {
            cellSelected = -1
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
        if week == nil {
           week = store.state.reportState.weeks.first
        }else{
            self.navigationItem.title = "Semana \(week.id!)"
        }
        
        store.subscribe(self){
            state in
            state.businessState
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    func newState(state: BusinessState) {
        self.enterprises = state.business
        week = store.state.reportState.weeks.first ?? week
        self.tableView.reloadData()
    }
}
