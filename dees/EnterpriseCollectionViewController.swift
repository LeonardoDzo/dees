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
    var enterprises = [[Business]]()
    var type: Int!
    var week: Week!
    var user: User!
    var entFather: Business!
    var count = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.07843137255, green: 0.1019607843, blue: 0.1647058824, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1215686275, green: 0.6901960784, blue: 0.9882352941, alpha: 1)
        self.tabBarController?.tabBar.barTintColor = #colorLiteral(red: 0.07843137255, green: 0.1019607843, blue: 0.1647058824, alpha: 1)
        self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.collectionView?.addGestureRecognizer(lpgr)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let p = gestureReconizer.location(in: self.collectionView)
        let indexPath = self.collectionView?.indexPathForItem(at: p)
        
        if let index = indexPath {
            if let e = enterprises.last?[index.item]{
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
        let addAction = UIAlertAction(title: "Agregar Empresa", style: .default, handler: {
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
        
        if e.business.count > 0  || enterprises.count == 1{
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
            e.ext = enterpriseFather.id
            guard let name = firstTextField.text, !name.isEmpty, (firstTextField.text?.characters.count)! > 4 else {
                
                return
            }
            e.name = name
            self.entFather = enterpriseFather
            store.dispatch(CreateBusinessAction(e: e))
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
        if store.state.userState.user.rol == .Superior {
      
            if let ent = enterprises[enterprises.count - 2].first(where: {$0.id == e.ext}){
                entFather = ent
            }
            
            store.dispatch(DeleteBusinessAction(id: e.id))
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "responsableSegue" {
            let vc = segue.destination as! ResponsableTableViewController
            vc.business = sender as! Business
            vc.week = week
            
        }else if segue.identifier == "enterpriseSegue" {
            let vc = segue.destination as! EnterpriseViewViewController
            vc.enterprise = sender as! Business
        }
    }

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
        switch (enterprises.last?.count)! {
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
    func setupNavBar() -> Void {
        
        
        let actions = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.preSelect(sender:)))
        
        self.navigationItem.rightBarButtonItems = []
        if enterprises.count == 1 {
            let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.back))
            self.navigationItem.leftBarButtonItem = nil
            if self.tabBarController?.selectedIndex == 0 && user.rol == .Superior {
                self.navigationItem.leftBarButtonItem = back
            }
        }else{
            let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.back2))
            self.navigationItem.leftBarButtonItem = back
            self.navigationItem.rightBarButtonItems = [actions]
        }
    }
    
    func preSelect(sender: UIBarButtonItem) -> Void {
        guard let ext = enterprises.last?[0].ext else {return}
        if let e = enterprises[enterprises.count-2].first(where: {$0.id == ext}){
            actionsEnterprise(e)
        }
    }
    
    func back2() -> Void {
        self.enterprises.removeLast()
        AnimatableReload.reload(collectionView: self.collectionView!, animationDirection: "right")
        setupNavBar()
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
         let e = enterprises.last!
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
        let e = enterprises.last?[indexPath.item]
        if (e?.business.count)! > 0 {
           
            enterprises.append((enterprises.last?[indexPath.item].business)!)
            setupNavBar()
            AnimatableReload.reload(collectionView: self.collectionView!, animationDirection: "left")
        }else{
            self.performSegue(withIdentifier: "responsableSegue", sender: e)
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
            state in
            state.businessState
        }
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    func newState(state: BusinessState) {
        self.user = store.state.userState.user
        enterprises.removeAll()
        user.rol == .Superior ? self.enterprises.append(state.business.filter({$0.type == type})) : self.enterprises.append(state.business.filter({b in
            return user.bussiness.contains(where: {ub in
                return b.id == ub.id || b.business.contains(where: {$0.id == ub.id})
            })
        }))
        setupNavBar()
        setTitle()
        collectionView?.reloadData()
        if entFather != nil {
            if let index = enterprises.last?.index(where: {entFather.id == $0.id}),  entFather.business.count > 0 {
                self.collectionView(self.collectionView!, didSelectItemAt: IndexPath(item: index, section: 0))
            }
        }
    }
    
    func setTitle(){
        
        if week == nil {
            week = store.state.reportState.weeks.first
        }else{
            
            self.navigationItem.titleView = UIView().setTitle(title: "Semana:", subtitle:  (Date(string:week.startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:week.endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!)
        }
        
    }
}

