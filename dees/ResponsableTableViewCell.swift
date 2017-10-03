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
     let notificationCenter = NotificationCenter.default
    @IBOutlet weak var tableView: UITableView!
    var reports = [Report]()
    var users = [User]()
    var enterprise : Business!
    lazy var loadingView : LoadingView = {
        let loading = LoadingView()
        loading.center = self.tableView.center
        loading.frame.origin.x -= (loading.loading.frame.width )
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
    
    func getMyReports() -> Void {
        guard let cell = tableView.visibleCells[0] as? RerportTableViewCell else {
            return
        }
        if let indexPath = self.tableView.indexPath(for: cell) {
            seen(indexPath)
        }
    }
    
    
    func setTableViewDataSourceDelegate() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tag = self.tag
        let xib = UINib(nibName: "TitleView", bundle: nil)
        tableView.register(xib, forHeaderFooterViewReuseIdentifier: "TitleHeaderCell")
        
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
        
        let uid = users[indexPath.section].id
        cell.report =  store.state.reportState.reports.first(where: {$0.eid == self.enterprise.id && $0.uid == uid && self.tag == $0.wid})
        cell.bind()
        print(self.tag)
        cell.tag = uid!
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TitleHeaderCell") as! TitleHeader
       let user = users[section]
        headerFooterView.titleLbl.text = user.name ?? "Sin nombre"
        headerFooterView.titleLbl.sizeToFit()
        headerFooterView.contentView.backgroundColor = #colorLiteral(red: 0, green: 0.3994623721, blue: 0.3697786033, alpha: 1)
        return headerFooterView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown  || UIDevice.current.orientation == .faceDown || UIDevice.current.orientation == .faceUp{
            return 575
        }
        return users.count > 1 ? 575 : 860
    }
    
    func seen(_ indexPath: IndexPath) -> Void {
        self.loadingView.stop()
        if users.count == 0 {
            return
        }
        guard let cell = tableView.cellForRow(at: indexPath) as? RerportTableViewCell else {
            return
        }
        let uid = users[indexPath.section].id
        cell.report = store.state.reportState.reports.first(where: {$0.eid == self.enterprise.id && $0.uid == uid && self.tag == $0.wid})
        if cell.report != nil {
            cell.bind()
        }else {
            self.loadingView.start()
            store.dispatch(ReportsAction.Get(eid: enterprise.id, wid: self.tag, uid: users[indexPath.section].id))
        }
    }
    
    func tableView(_  tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.visibleCells.contains(cell){
            seen(indexPath)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //scrollTo(scrollView)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            scrollTo(scrollView)
        }
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollTo(scrollView)
    }
    
    func scrollTo(_ scrollView: UIScrollView) -> Void {
        if var indexPath = tableView.indexPathForRow(at: scrollView.contentOffset) {
            
            if scrollView.contentOffset.y >= self.tableView.rowHeight/2 {
                indexPath.section +=  users.count-1 == indexPath.section ? 0 : 1
            }
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            seen(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
}
