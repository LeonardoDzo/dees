//
//  ReponsableCollectionViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 09/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Whisper
private let reuseIdentifier = "Cell"

class ReponsableCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    var business: Business!
    var week: Week!
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addUser))
        self.navigationItem.rightBarButtonItem = addButton
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
    
    func addUser() -> Void {
        self.performSegue(withIdentifier: "usersSegue", sender: business)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reportSegue" {
            let vc =  segue.destination as! ReportViewController
            vc.user = sender as! User
            vc.business = business
            vc.week = week
        }else if segue.identifier == "usersSegue" {
            let vc = segue.destination as! UsersTableViewController
            vc.enterprise = sender as! Business
        }
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = business.users[indexPath.item]
        if store.state.userState.user.rol == .Superior || store.state.userState.user.id == user.id{
            self.performSegue(withIdentifier: "reportSegue", sender: user)
        }
        
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return business.users.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ResponsableCollectionViewCell
        let user = business.users[indexPath.item]
        cell.bind(user: user)
        // Configure the cell
        
        return cell
    }
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let p = gestureReconizer.location(in: self.collectionView)
        let indexPath = self.collectionView?.indexPathForItem(at: p)
        
        if let index = indexPath {
            let u = business.users[index.item]
            let alertView = UIAlertController(title: "\(business.name!)", message: "Desea sacar a: \(u.name!) de la empresa?", preferredStyle: .alert)
            let action = UIAlertAction(title: "Eliminar", style: .destructive, handler: { (alert) in
                store.dispatch(DeleteUserBusinessAction(uid: u.id!, bid: self.business.id))
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            alertView.addAction(action)
            alertView.addAction(cancelAction)
            self.present(alertView, animated: true, completion: nil)
            
        } else {
        }
    }
    
 

}
extension ReponsableCollectionViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = AppState
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.titleView = UIView().setTitle(title: business.name!, subtitle:  (Date(string:week.startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:week.endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!)
        store.subscribe(self) {
            state in
            state
        }
        store.dispatch(GetBusinessAction(id: business.id))
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
        Whisper.hide(whisperFrom: navigationController!)
    }
    
    func newState(state: AppState) {
        
        
        switch state.businessState.status {
        case .loading:
            break
        case .finished:
            Whisper.show(whisper: messages.succesG, to: navigationController!, action: .present)
            break
        case .failed:
            Whisper.show(whisper: messages.errorG, to: navigationController!, action: .present)
            break
        default:
            state.businessState.business.enumerated().forEach({
                index, b in
                if b.id == business?.id {
                    business = store.state.businessState.business[index]
                    return
                }else{
                    b.business.enumerated().forEach({
                        i2, b2 in
                        if b2.id == business?.id {
                             business = store.state.businessState.business[index].business[i2]
                            return
                        }
                    })
                }
            })
            collectionView?.reloadData()
            break
        }
        
    }
}
