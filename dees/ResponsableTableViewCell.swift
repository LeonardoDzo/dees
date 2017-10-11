//
//  ResponsableTableViewCell.swift
//  dees
//
//  Created by Leonardo Durazo on 11/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Whisper
import KDLoadingView
class ResponsableTableViewCell: UITableViewCell {
    let notificationCenter = NotificationCenter.default
    var gotoProtocol : GoToProtocol!
    var changeEnterpriseProtocol : EnterpriseProtocol!
    var lastContentOffset: CGFloat = 0
    @IBOutlet weak var tableView: UITableView!
    var reports = [Report]()
    var users = [User]()
    /// Bandera que sirve para moverme entre usaurios
    var lastsection = 0
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
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(sender:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(sender:)))
        swipeRight.direction = .right
        self.tableView.addGestureRecognizer(swipeLeft)
        self.tableView.addGestureRecognizer(swipeRight)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func swipe(sender: UISwipeGestureRecognizer) {
        changeUser(direction: sender.direction == .right ? .left : .right)
    }
    
    func changeUser(direction: UISwipeGestureRecognizerDirection) {
        if direction == .left {
            self.lastsection -= 1
        }else if direction == .right{
            self.lastsection += 1
        }
        
        if lastsection > users.count-1 {
            changeEnterpriseProtocol.changeEnterprise(direction: direction)
            return
        }else if lastsection < 0 {
            changeEnterpriseProtocol.changeEnterprise(direction: direction)
            return
        }
        
        let indexpath = IndexPath(row: 0, section: lastsection)
        self.tableView.scrollToRow(at: indexpath, at: .top, animated: true)
    }
    
    func getMyReports() -> Void {
        guard let cell = tableView.visibleCells[0] as? RerportTableViewCell else {
            return
        }
        if let indexPath = self.tableView.indexPath(for: cell) {
            get(indexPath)
        }
    }
    func getUser() -> User? {
        guard let cell = tableView.visibleCells[0] as? RerportTableViewCell else {
            return nil
        }
        if let indexPath = self.tableView.indexPath(for: cell) {
            return users[indexPath.section]
        }
        return nil
    }
    func updated() {
        self.loadingView.stop()
        guard tableView.visibleCells.count > 0 , let cell = tableView.visibleCells[0] as? RerportTableViewCell else {
            return
        }
        if let indexPath = self.tableView.indexPath(for: cell) {
            let uid = users[indexPath.section].id
            getReports()
            cell.report =  reports.first(where: {$0.eid == self.enterprise.id && $0.wid == self.tag && $0.uid == uid})
            cell.bind()
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
        if enterprise.users.count == 0 {
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
        getReports()
        cell.report =  reports.first(where: {$0.eid == self.enterprise.id && $0.wid == self.tag && $0.uid == uid})
        cell.bind()
        
        
        cell.gotoProtocol = gotoProtocol
        cell.tag = uid!
        return cell
    }
    
    func getReports() -> Void {
        switch store.state.reportState.reports {
        case .failed:
            let m = messages.error._00
            Whisper.show(whistle: m, action: .show(3.0))
            break
        case .Finished(let tupla as (Report, Murmur)):
            if !reports.contains(where: {tupla.0.id == $0.id}){
                reports.append(tupla.0)
            }else if let index = reports.index(where: {$0.id == tupla.0.id}) {
                reports[index] = tupla.0
            }
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TitleHeaderCell") as! TitleHeader
        let user = users[section]
        let name = "Resp. \(section+1): \(String(describing: user.name!))"
        if name.count > 23 {
            headerFooterView.titleLbl.font = headerFooterView.titleLbl.font.withSize(11)
        }else{
            headerFooterView.titleLbl.font = headerFooterView.titleLbl.font.withSize(13)
        }
        headerFooterView.titleLbl.text = name
        headerFooterView.titleLbl.sizeToFit()
        headerFooterView.contentView.backgroundColor = #colorLiteral(red: 0, green: 0.3994623721, blue: 0.3697786033, alpha: 1)
        return headerFooterView
    }
    

    func get(_ indexPath: IndexPath) -> Void {
        self.loadingView.stop()
        if users.count == 0 {
            return
        }
        
        if let uid = users[indexPath.section].id {
                store.dispatch(ReportsAction.Get(eid: self.enterprise.id, wid: self.tag, uid: uid))
        }
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let indexPath = tableView.indexPathForRow(at: visiblePoint)
        get(indexPath!)
    }
    
    
    func update() -> Void {
        if  tableView.visibleCells.count > 0 {
            tableView.visibleCells.forEach({ cell  in
                if let xcell = cell as? RerportTableViewCell {
                    xcell.update()
                }
            })
        }
    }
    
}
extension ResponsableTableViewCell {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            cellMostVisible()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        cellMostVisible()
    }
    
    func cellMostVisible() {
        let visibleRect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let indexPath = tableView.indexPathForRow(at: visiblePoint)
        let count = tableView.indexPathsForVisibleRows?.count ?? 1
        if count > 1 {
            tableView.scrollToRow(at: indexPath!, at: .top, animated: true)
        }
    }
}
