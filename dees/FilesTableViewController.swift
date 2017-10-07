//
//  FilesTableViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 04/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import PDFKit
class FilesTableViewController: UITableViewController, UINavigationControllerDelegate {
    var files = [File]()
    var enterprise: Business!
    var user: User!
    var type: Int!
    var report: Report!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleNavBarAndTab_1()
        let attachBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "Attach").maskWithColor(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)), style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = attachBtn
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
        return files.count
    }
    override func viewWillAppear(_ animated: Bool) {
        files = report.files.filter({$0.type == type})
        var name = type != 0 ? "Financiero de " : "Operativo de "
        name.append(user.name!)
        self.navigationItem.titleView = titleNavBarView(title: enterprise.name!, subtitle: name)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsSegue" {
            let vc = segue.destination as! FileViewViewController
            vc.file = sender as! File
        }
    }

}
