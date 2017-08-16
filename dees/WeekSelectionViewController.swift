//
//  WeekSelectionViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
protocol Segue: class {
    func selected(_ segue: String, sender: Any?) -> Void
}
class WeekSelectionViewController: UITableViewController, Segue {
    var week: Week!
    var user: User!
    var enterprises = [Business]()
    var type: Int!
    
    var cellSelected = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.formatView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selected(_ segue: String, sender: Any?) {
        self.performSegue(withIdentifier: segue, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "responsableSegue" {
            let vc = segue.destination as! ReponsableCollectionViewController
            vc.business = sender as! Business
            vc.week = week
        }
    }
    
}
extension WeekSelectionViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enterprises.count*2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BusinessTableViewCell
            let e = enterprises[Int(indexPath.row/2)]
            if  e.business.count > 0 {
                cell.arrowImg.isHidden = false
                cell.accessoryType = .none
                if cellSelected - 1 != indexPath.row {
                    cell.arrowImg.image = #imageLiteral(resourceName: "expand")
                }else{
                    cell.arrowImg.image = #imageLiteral(resourceName: "collapse")
                }
            }else{
                cell.arrowImg.isHidden = true
                cell.accessoryType = .detailDisclosureButton
            }
            cell.title.text = "\(e.name!)"
            if e.color != nil {
                cell.colorLbl.backgroundColor = UIColor(hexString: "#\(e.color!)ff")
            }
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! ChildTableViewCell
        let e = enterprises[(indexPath.row-1)/2]
        
        cell.data = e
        cell.segueDelegate = self
        cell.tableView.reloadData()
        cell.chageHeight()
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return 60.0
        }else{
            if indexPath.row == cellSelected {
                let e = enterprises[(indexPath.row-1)/2]
                let value = e.business.count
                let heigtht = value * 44
                return CGFloat(heigtht)
            }
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            let e = enterprises[indexPath.row/2]
            if e.business.count == 0{
                self.performSegue(withIdentifier: "responsableSegue", sender: e)
                return
            }
        }
        if indexPath.row == cellSelected - 1 {
            cellSelected = -1
        }else{
            if cellSelected != -1 {
                tableView.reloadData()
            }
            cellSelected = indexPath.row + 1
        }
        tableView.reloadRows(at: [indexPath,], with: .automatic)
        
        
    }
}
extension WeekSelectionViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = BusinessState
    
    override func viewWillAppear(_ animated: Bool) {
        setTitle()
        store.subscribe(self){
            state in
            state.businessState
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    func commonElements<T: Sequence, U: Sequence>(_ lhs: T, _ rhs: U) -> [T.Iterator.Element]
        where T.Iterator.Element: Equatable, T.Iterator.Element == U.Iterator.Element {
            var common: [T.Iterator.Element] = []
            
            for lhsItem in lhs {
                for rhsItem in rhs {
                    if lhsItem == rhsItem {
                        common.append(lhsItem)
                    }
                }
            }
            return common
    }
    
    func newState(state: BusinessState) {
        self.user = store.state.userState.user
        self.enterprises = user.rol == .Superior ? state.business : state.business.filter({b in
            return user.bussiness.contains(where: {ub in
                return b.id == ub.id || b.business.contains(where: {$0.id == ub.id})
            })
        })
        
        setTitle()
        self.tableView.reloadData()
    }
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame:  CGRect(x:0,y:-2,width: 0,height: 0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.darkGray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x:0,y:18,width: 0,height: 0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.black
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x:0, y:0, width: max(titleLabel.frame.size.width,subtitleLabel.frame.size.width), height:30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        
        return titleView
    }
    
    func setTitle(){
        if week == nil {
            week = store.state.reportState.weeks.first
        }else{
            let view = setTitle(title: "Semana \(week.id!)", subtitle: (Date(string:week.startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:week.endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!)
            self.navigationItem.titleView = view
        }
        
    }
}
