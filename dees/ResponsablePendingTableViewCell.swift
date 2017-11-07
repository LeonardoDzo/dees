//
//  ResponsablePendingTableViewCell.swift
//  dees
//
//  Created by Leonardo Durazo on 18/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ResponsablePendingTableViewCell: UITableViewCell {
    var model : pendingModel!
    var toggle = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         setTableViewDataSourceDelegate()
    }
    func setTableViewDataSourceDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tag = self.tag
        self.tableView.reloadData()
       
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var tableView: UITableView!
    
 

}
extension ResponsablePendingTableViewCell : UITableViewDelegate, UITableViewDataSource, ExpandableHeaderViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return model != nil ? model.users.count : 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return model.users[section].weeks.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "childCell", for: indexPath)
        let week = model.users[indexPath.section].weeks[indexPath.row]
        cell.textLabel?.text = "Semana \(week.getTitleOfWeek())"
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderView()
        header.customInit(title: model.users[section].user.name!, section: section, delegate: self)
        
        return header
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    func toggleSection(header: ExpandableHeaderView, section: Int) {
       
      //CLICK
    }
    

}
