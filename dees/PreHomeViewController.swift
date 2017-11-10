 //
//  PreHomeViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 15/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Whisper
protocol preHomeProtocol : class {
    var section : MENU_PRE {get set}
    func handleClick(sender: Int) -> Void
}
var enterprisesNav = [[Business]]()
class PreHomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var section = MENU_PRE.ENTRAR
    var enterprises = [Business]()
    var enterprise : Int!
    var week: Week!
    override func viewDidLoad() {
        super.viewDidLoad()
       NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
       
    }
    override func viewWillAppear(_ animated: Bool) {
        verifyEnterprises()
        store.subscribe(self) {
            $0.select({ subscription in
                subscription.businessState
            })
        }
    }
    override func viewDidAppear(_ animated: Bool) {
         //let cell = self.collectionView?.cellForItem(at: IndexPath(item: 0, section: 0)) as! preHomeCollectionViewCell
         //let _ = AnimationController(target: self, controls: [])
        generatePDF()
    }
    
    
    func generatePDF() -> Void {
        
        if week != nil, enterprise != nil {
            let name = enterprises[enterprise].name
            
            
            
            let alert = UIAlertController(title: "Generar PDF de: ", message: name!  + " de la semana \(self.week.getTitleOfWeek())", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: { _ in
                self.enterprise = nil
                self.week = nil
            }))
            
            alert.addAction(UIAlertAction(title: "Ver", style: .default, handler: { (_alert) in
                
                self.pushToView(view: .webView, sender: "companies/\(self.enterprise + 1 )/res/week/\(self.week.id!)/generate" )
                self.enterprise = nil
                self.week = nil
            }))
        
            
            present(alert, animated: true, completion:nil)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSegue" {
            let tb = segue.destination as! UITabBarController
            tb.selectedIndex = section.hashValue
            singleton.enterpriseNav.removeAll()
            singleton.enterpriseNav.push(enterprises)
            
            if let nb  = tb.childViewControllers[section.hashValue] as? UINavigationController {
                if let vc = nb.childViewControllers[0] as? EnterpriseCollectionViewController {
                    vc.type = sender  as! Int + 1
                }else  if let vc = nb.childViewControllers[0] as? AllReportsTableViewController {
                    vc.type = sender as! Int + 1
                    
                }
                store.state.userState.type = sender as! Int + 1
            }
           
        }
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return enterprises.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! preHomeCollectionViewCell
        let e = enterprises[indexPath.row]
        cell.tag = indexPath.row
        cell.prehome = self
        if e.id == 2 {
            cell.backgroundImg.image = #imageLiteral(resourceName: "background-gde")
            cell.mainLogo.image = #imageLiteral(resourceName: "gde")
        }else{
            cell.backgroundImg.image = #imageLiteral(resourceName: "background-opessa")
            cell.mainLogo.image = #imageLiteral(resourceName: "opessa-1")
        }
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleClick(sender: indexPath.item)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = 0
        var width = 0
        //entra al if si el celular esta de lado o acostado
        if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown  || UIDevice.current.orientation == .faceDown || UIDevice.current.orientation == .faceUp{
            height = Int(((self.collectionView?.frame.height)!)/CGFloat(enterprises.count) )
            width = Int((self.collectionView?.frame.width)!)
        }else{
            height = Int((self.collectionView?.frame.height)!)
            width = Int((self.collectionView?.frame.width)!/CGFloat(enterprises.count))
        }
        
        return CGSize(width: width, height: height)
    }
    @objc func rotated() {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            collectionView?.reloadData()
        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            collectionView?.reloadData()
        }
        
    }

 }
extension PreHomeViewController : preHomeProtocol {
    func handleClick(sender: Int) {
        if enterprises.count > 0, section != .PDF {
            enterprises = enterprises[sender].business
            self.performSegue(withIdentifier: "infoSegue", sender: sender)
        }else{
            enterprise = sender
            self.pushToView(view: .weeksView, sender: self)
        }
    }

}
 extension PreHomeViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = BusinessState
    func newState(state: BusinessState) {
 
        switch state.status {
        case .loading:
            
            break
        case .finished:
            
            collectionView?.reloadData()
            verifyEnterprises()
            break
        case .Failed(let m as Murmur):
            Whisper.show(whistle: m, action: .show(3.0))
            break
        default:
            break
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
        //Whisper.hide(whisperFrom: self.navigationController!)
    }
    
    func verifyEnterprises() -> Void {
        enterprises = store.state.businessState.business.count > 0 ? store.state.businessState.business.sorted(by: {$0.id < $1.id}) : store.state.userState.user.bussiness.filter({$0.parentId == nil })
        if enterprises.count == 0 {
            self.enterprises = store.state.userState.user.bussiness
            self.performSegue(withIdentifier: "infoSegue", sender: 0)
            return
        }
    }
 }
