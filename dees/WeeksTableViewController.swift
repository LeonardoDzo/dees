//
//  WeeksTableViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
class WeeksTableViewController: UITableViewController {
    var weeks = [Week]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleNavBarAndTab_1()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationItem.title = "Semanas"
        tableView.tableFooterView = UIView(frame: .zero)
        
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
        return weeks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let w = weeks[indexPath.row]
        cell.textLabel?.text = "Semana"
        cell.detailTextLabel?.text = (Date(string:w.startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:w.endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
            if let vc =  navController.viewControllers[navController.viewControllers.count - 2] as? weekProtocol {
                vc.weekSelected = indexPath.row
                self.navigationController?.popViewController(animated: true)
            }
           
          
        }
    }


}
extension WeeksTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = WeekState
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self) {
            $0.select({s in s.weekState})
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    func newState(state: WeekState) {
        switch state.weeks {
        case .loading:
            print("Cargando")
            break
        case .Finished(let w as [Week]):
            weeks = w
             self.tableView.reloadData()
            break
        default:
            break
        }
       
    }
    
}
