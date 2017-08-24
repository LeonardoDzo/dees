//
//  EnterpriseCollectionViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 23/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import AnimatableReload
import ReSwift
private let reuseIdentifier = "Cell"

class EnterpriseCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var enterprises = [[Business]]()
    var type: Int!
    var week: Week!
    var user: User!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return enterprises.last?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let id = "CELL2"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! EnterpriseCollectionViewCell
        let e = enterprises.last?[indexPath.item]
        cell.nameLbl.text = e?.name!
        cell.background.image = #imageLiteral(resourceName: "background_company3c")
        if e?.color != nil {
            cell.colorLbl.backgroundColor = UIColor(hexString: "#\(e?.color!)ff")
        }
        // Configure the cell
     
        return cell
    }
    func setupNavBar() -> Void {
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.back2))
        self.navigationItem.leftBarButtonItem = back
        
        if enterprises.count == 1 {
            let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.back))
            
            if self.tabBarController?.selectedIndex == 0 && user.rol == .Superior {
                self.navigationItem.leftBarButtonItem = back
            }
        }
    }
    func back2() -> Void {
        self.enterprises.removeLast()
        setupNavBar()
         AnimatableReload.reload(collectionView: self.collectionView!, animationDirection: "right")
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
         let e = enterprises.last
        if e?.count == 1 {
            return CGSize(width: (self.collectionView?.frame.size.width)!, height: (self.collectionView?.frame.height)!-60)
        }else if e?.count == 2 {
            return CGSize(width: (self.collectionView?.frame.size.width)!, height: (self.collectionView?.frame.height)!/2-60)
        }else{
            return CGSize(width: (self.collectionView?.frame.size.width)!/2, height: 120)
        }
        
    }
   
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (enterprises.last?[indexPath.item].business.count)! > 0 {
            enterprises.append((enterprises.last?[indexPath.item].business)!)
            setupNavBar()
            AnimatableReload.reload(collectionView: self.collectionView!, animationDirection: "left")
        }
    }
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
extension EnterpriseCollectionViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = BusinessState
    
    override func viewWillAppear(_ animated: Bool) {
        setTitle()
        if type == nil {
            type = store.state.userState.type
        }else{
            store.state.userState.type = type
        }
        store.subscribe(self){
            state in
            state.businessState
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    func newState(state: BusinessState) {
        self.user = store.state.userState.user
        
        user.rol == .Superior ? self.enterprises.append(state.business.filter({$0.type == type})) : self.enterprises.append(state.business.filter({b in
            return user.bussiness.contains(where: {ub in
                return b.id == ub.id || b.business.contains(where: {$0.id == ub.id})
            })
        }))
        setupNavBar()
        setTitle()
         AnimatableReload.reload(collectionView: self.collectionView!, animationDirection: "up")
    }
    
    func setTitle(){
        
        if week == nil {
            week = store.state.reportState.weeks.first
        }else{
            
            self.navigationItem.titleView = UIView().setTitle(title: "Semana:", subtitle:  (Date(string:week.startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:week.endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!)
        }
        
    }
}

