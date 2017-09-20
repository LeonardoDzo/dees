//
//  ResponsableTableViewCell.swift
//  dees
//
//  Created by Leonardo Durazo on 11/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import KDLoadingView
class ResponsableTableViewCell: UITableViewCell {
    var enterprise: Business!
    @IBOutlet weak var tableView: UITableView!
    var report : Report!
    var indexPath : IndexPath!
    override func awakeFromNib() {
        super.awakeFromNib()
        setTableViewDataSourceDelegate()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func setTableViewDataSourceDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tag = self.tag
    }
    
}
extension ResponsableTableViewCell : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return enterprise != nil ? enterprise.users.count : 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RerportTableViewCell
        if let report = store.state.reportState.reports.first(where: {$0.uid == enterprise.users[indexPath.section].id && $0.eid == self.enterprise.id && $0.wid == self.tag }) {
            self.report = report
        }else {
            self.report = Report(uid: enterprise.users[indexPath.section].id!, eid: self.enterprise.id, wid: self.tag)
        }
        cell.bind(by: report)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.tintColor = #colorLiteral(red: 0.08339247853, green: 0.1178589687, blue: 0.1773400605, alpha: 1)
        view.backgroundColor = #colorLiteral(red: 0.08339247853, green: 0.1178589687, blue: 0.1773400605, alpha: 1)
        let lbl = UILabel()
        lbl.text = enterprise.users[section].name
        lbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        lbl.backgroundColor = #colorLiteral(red: 0, green: 0.3994623721, blue: 0.3697786033, alpha: 1)
        lbl.frame = CGRect(x: 0, y: 12, width: Int(self.tableView.frame.width), height: 44)
        lbl.textAlignment = .center
        view.addSubview(lbl)
        return view
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown  || UIDevice.current.orientation == .faceDown || UIDevice.current.orientation == .faceUp{
            return 575
        }
        return enterprise.users.count > 1 ? 575 : 860
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        if self.report.operative != "true" {
            self.report.operative = "true"
            store.dispatch(ReportsAction.Post(report: self.report))
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
          isLoading(indexPath: indexPath)
    }
    func isLoading(indexPath: IndexPath) -> Void {
        if let cell = self.tableView.cellForRow(at: indexPath) as? RerportTableViewCell {
            cell.loadingView.startAnimating()
            switch store.state.reportState.status {
            case .loading:
                cell.loadingView.startAnimating()
                break
            default:
                break
            }
        }
       
    }
}
