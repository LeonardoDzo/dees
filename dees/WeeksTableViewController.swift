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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        cell.textLabel?.text = "Semana \(w.id!)"
        cell.detailTextLabel?.text = (Date(string:w.startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:w.endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "infoSegue", sender:weeks[indexPath.row])
    }
   

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSegue" {
            let vc = segue.destination as! WeekSelectionViewController
            vc.week = sender as? Week
            
        }
    }


}
extension WeeksTableViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = ReportState
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self) {
            state in
            state.reportState
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    func newState(state: ReportState) {
        weeks = state.weeks
        switch state.status {
        case .loading:
            break
        default:
            break
        }
    }
    
}
