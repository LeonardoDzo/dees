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

class EnterpriseCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    var enterprisesNav = singleton.enterpriseNav
    var type: Int!
    var week: Week!
    var user: User!
    var entFather: Business!
    var count = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleNavBarAndTab_1()
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureReconizer:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView?.addGestureRecognizer(lpgr)
        self.collectionView?.addGestureRecognizer(tapGesture)
        self.hideKeyboardWhenTappedAround()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return enterprisesNav.items.last?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let id = "CELL2"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! EnterpriseCollectionViewCell
        let e = enterprisesNav.items.last?[indexPath.item]
        cell.nameLbl.text = e?.name!
        
        switch (enterprisesNav.items.last?.count)! {
        case 1:
             cell.background.image = #imageLiteral(resourceName: "background_company1")
            break
        case 2:
            if count == 1 {
                cell.background.image = #imageLiteral(resourceName: "background_company2a")
                count = 2
            }else{
                cell.background.image = #imageLiteral(resourceName: "background_company2b")
                count = 1
            }
            break
        default:
            switch count {
            case 1:
                cell.background.image = #imageLiteral(resourceName: "background_company3a")
                break
            case 2:
                cell.background.image = #imageLiteral(resourceName: "background_company3b")
                break
            case 3:
                cell.background.image = #imageLiteral(resourceName: "background_company3c")
                break
            default:
                cell.background.image = #imageLiteral(resourceName: "background_company3d")
                count = 0
                break
            }
            count += 1
        break
            
        }
        
        if e?.color != nil {
            cell.colorLbl.backgroundColor = UIColor(hexString: "#\(e?.color! ?? "000000")ff")
        }
        cell.setupView()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
         let e = enterprisesNav.items.last!
        
        if e.count == 1 {

            return CGSize(width: (self.collectionView?.frame.size.width)!, height: (self.collectionView?.frame.height)!-60)
        }else if e.count == 2 {
            return CGSize(width: (self.collectionView?.frame.size.width)!, height: (self.collectionView?.frame.height)!/2-60)
        }else{
            var c =  (self.collectionView?.frame.height)!/CGFloat(e.count)
            c = c > 100 ? c : 150
            return CGSize(width: (self.collectionView?.frame.size.width)!/2, height: c)
        }
        
    }
   
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let e = enterprisesNav.items.last?[indexPath.item]
        if (e?.business.count)! > 0 {
            enterprisesNav.push((e?.business)!)
            setupNavBar()
            AnimatableReload.reload(collectionView: self.collectionView!, animationDirection: "left")
        }else{
            self.pushToView(view: .allReports, sender: e)
        }
    }
    @objc func handleTapPress(gestureReconizer: UITapGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let p = gestureReconizer.location(in: self.collectionView)
        if let indexPath = self.collectionView?.indexPathForItem(at: p) {
            let e = enterprisesNav.items.last?[(indexPath.item)]
            if (e?.business.count)! > 0 {
                enterprisesNav.push((e?.business)!)
                setupNavBar()
                AnimatableReload.reload(collectionView: self.collectionView!, animationDirection: "left")
            }else{
                self.pushToView(view: .allReports, sender: e)
            }
        }
    }


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
            $0.select({
                s in s.businessState
            })
        }
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    func newState(state: BusinessState) {
        self.user = store.state.userState.user
        setupNavBar()
        setTitle()
        collectionView?.reloadData()

    }
    
    func setTitle(){
        
        if week == nil {
            week = store.state.weekState.getWeeks().first
        }else{
            self.navigationItem.titleView = titleNavBarView(title: "Semana:", subtitle:  (Date(string:week.startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:week.endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!)
        }
        
    }
}
extension EnterpriseCollectionViewController {
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let p = gestureReconizer.location(in: self.collectionView)
        let indexPath = self.collectionView?.indexPathForItem(at: p)
        
        if let index = indexPath {
            if let e = enterprisesNav.items.last?[index.item]{
                actionsEnterprise(e)
            }
        }
    }
    
    func actionsEnterprise(_ e: Business) -> Void {
        let alertController = UIAlertController(title: "Acción", message:nil, preferredStyle: .actionSheet)
        
        let profileAction = UIAlertAction(title: "Ver Perfil", style: .default, handler: {
            alert -> Void in
            self.performSegue(withIdentifier: "enterpriseSegue", sender: e)
        })
        let addAction = UIAlertAction(title: "Ver Reporte", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.pushToView(view: .allReports, sender: e)
        })
        let reportAction = UIAlertAction(title: "Agregar Empresa", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.add(e)
        })
        let deleteAction = UIAlertAction(title: "Eliminar", style: .destructive, handler: {
            (action : UIAlertAction!) -> Void in
            self.delete(e)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        NotificationCenter.default.addObserver(self, selector: #selector(alertController.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(alertController.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        alertController.addAction(reportAction)
        if e.business.count > 0  || enterprisesNav.items.count == 1{
            alertController.addAction(addAction)
        }else{
            alertController.addAction(deleteAction)
        }
        
        alertController.addAction(profileAction)
        alertController.addAction(cancelAction)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    func add(_ enterpriseFather: Business) -> Void {
        let alertController = UIAlertController(title: "Cambiar Nombre", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Guardar", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            var e = Business()
            e.color = enterpriseFather.color
            e.type = enterpriseFather.type
            e.parentId = enterpriseFather.id
            guard let name = firstTextField.text, !name.isEmpty, (firstTextField.text?.characters.count)! > 4 else {
                
                return
            }
            e.name = name
            self.entFather = enterpriseFather
            store.dispatch(baction.Create(e: e))
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Cual es el nombre?"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    func delete(_ e: Business) -> Void {
        if store.state.userState.user.permissions.contains(where: { $0.rid.rawValue >= 602 }){
            store.dispatch(baction.Delete(id: e.id))
        }
    }
    func setupNavBar() -> Void {
        
        
        //let actions = UIBarButtonItem(barButtonSystemItem: #imageLiteral(resourceName: "more_icon_vertical") as UIBarButtonSystemItem, target: self, action: #selector(self.preSelect(sender:)))
        let actions = UIBarButtonItem(image: #imageLiteral(resourceName: "more_icon_vertical"), style: .plain, target: self, action: #selector(self.preSelect(sender:)))
        self.navigationItem.rightBarButtonItems = []
        if enterprisesNav.items.count == 1 {
            let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.back))
            self.navigationItem.leftBarButtonItem = nil
            
            if self.tabBarController?.selectedIndex == 0 && store.state.userState.user.permissions.contains(where: {$0.rid.rawValue >= 602}) {
                self.navigationItem.leftBarButtonItem = back
            }
        }else{
            let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.back2))
            self.navigationItem.leftBarButtonItem = back
            self.navigationItem.rightBarButtonItems = [actions]
        }
    }
    
    @objc func preSelect(sender: UIBarButtonItem) -> Void {
        guard let ext = enterprisesNav.items.last?[0].parentId else {return}
        if let e = enterprisesNav.items[enterprisesNav.items.count-2].first(where: {$0.id == ext}){
            actionsEnterprise(e)
        }
    }
    
    @objc func back2() -> Void {
        _ = enterprisesNav.pop()
        AnimatableReload.reload(collectionView: self.collectionView!, animationDirection: "right")
        setupNavBar()
    }

}


