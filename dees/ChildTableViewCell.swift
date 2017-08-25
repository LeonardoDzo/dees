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
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.tableView?.addGestureRecognizer(lpgr)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tag = self.tag
        tableView.reloadData()
        
    }
    func chageHeight() -> Void {
        let value = data != nil ? data.business.count : 0
        tableHeight.constant = CGFloat( (value + 1) * 44)
    }
    
}
extension ChildTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let value = data != nil ? data.business.count : 0
        return value + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == data.business.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellAdd", for: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! BusinessTableViewCell
        let e = data.business[indexPath.row]
        //store.state.businessState.business.first(where: {$0.id == data.id})?.business?[indexPath.row].color = data.color
        data.business[indexPath.row].color = data.color
        cell.colorLbl.backgroundColor = UIColor(hexString: "#\(data.color!)ff")
        cell.accessoryType = .detailDisclosureButton
        cell.title.text = "  ·  \(e.name!)"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == data.business.count {
          //  segueDelegate.selected("", sender:  data)
            return
        }
        //segueDelegate.selected("responsableSegue", sender: data.business[indexPath.row])
        

        
    }
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let p = gestureReconizer.location(in: self.tableView)
        let indexPath = self.tableView?.indexPathForRow(at: p)
        
        if let index = indexPath {
            let e = data.business[(index.row)]
            //segueDelegate.selected("enterpriseSegue", sender: e)
        } else {
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.row == data.business.count {
            return nil
        }
        let delete = UITableViewRowAction(style: .destructive, title: "Eliminar") { action, index in
            let e = self.data.business[(index.row)]
            if store.state.userState.user.rol == .Superior {
                store.dispatch(DeleteBusinessAction(id: e.id))
            }
        }
        return [delete]
    }
    
}
