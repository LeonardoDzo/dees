//
//  ChildTableViewCell.swift
//  dees
//
//  Created by Leonardo Durazo on 08/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ChildTableViewCell: UITableViewCell {
    var data : Business!
    weak var segueDelegate : Segue!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setTableViewDataSourceDelegate()
    }
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func setTableViewDataSourceDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tag = self.tag
        tableView.reloadData()
        
    }
    func chageHeight() -> Void {
        let value = data != nil ? data.business?.count ?? 0 : 0
        tableHeight.constant = CGFloat( value * 44)
    }
    
}
extension ChildTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let value = data != nil ? data.business?.count ?? 0 : 0
        return value
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! BusinessTableViewCell
        let e = data.business?[indexPath.row]
        cell.colorLbl.backgroundColor = UIColor(hexString: "#\(data.color!)ff")
        cell.title.text = "  \(indexPath.row+1).-  \(e!.name!)"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        segueDelegate.selected("responsableSegue", sender: data.business?[indexPath.row])
        

        
    }
    
}
