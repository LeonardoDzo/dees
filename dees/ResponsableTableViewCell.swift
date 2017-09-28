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
    
    @IBOutlet weak var tableView: UITableView!
    var reports = [Report]()
    var enterprise: Business!
    var users = [User]()
    /// Variable como tag que me ayuda a identificar si se ha hecho o no el request por el reporte
    var avaible = false
    lazy var loadingView : LoadingView = {
        let loading = LoadingView()
        loading.center = self.tableView.center
        loading.frame.origin.x -= loading.loading.frame.width/2
        loading.frame.origin.y -= loading.loading.frame.width
        return loading
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        setTableViewDataSourceDelegate()
        self.tableView.addSubview(loadingView)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func setTableViewDataSourceDelegate() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tag = self.tag
        
        self.loadingView.center = tableView.center
        self.loadingView.frame.origin.x -= self.loadingView.loading.frame.width/2
        self.loadingView.frame.origin.y -= self.loadingView.loading.frame.width
    }
    
}
extension ResponsableTableViewCell : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if enterprise == nil {
            return 0
        }
        if store.state.businessState.business.count == 0 {
            self.users = [store.state.userState.user]
        }else{
            self.users = enterprise.users
        }
        
        return users.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RerportTableViewCell
        let uid = enterprise.users[indexPath.section].id
        cell.report = reports.first(where: { $0.uid == uid})
        cell.bind()
        print(self.tag)
        cell.tag = uid!
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
    
    func seen(_ indexPath: IndexPath) -> Void {
        self.loadingView.stop()
        if enterprise.users.count == 0 {
            return
        }
        guard let cell = tableView.cellForRow(at: indexPath) as? RerportTableViewCell else{
            return
        }
        
        if avaible {
            if cell.report == nil || !cell.report.reply!  {
                let uid = enterprise.users[indexPath.section].id
                cell.report = reports.first(where: { $0.uid == uid}) ?? Report(uid: uid!, eid: enterprise.id, wid: self.tag)
                cell.bind()
                cell.update()
            }
        }else {
            self.loadingView.start()
            store.dispatch(ReportsAction.Get(eid: enterprise.id, wid: self.tag, uid: users[indexPath.section].id))
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.visibleCells.contains(cell){
            seen(indexPath)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("X: ", scrollView.contentOffset.x, "Y: ",  scrollView.contentOffset.y)
        if let indexPath = tableView.indexPathForRow(at: scrollView.contentOffset) {
            seen(indexPath)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}
