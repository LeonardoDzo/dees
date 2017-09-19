//
//  PreHomeViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 15/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class PreHomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        if store.state.userState.user.rol != .Superior {
            self.performSegue(withIdentifier: "infoSegue", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleTouch(_ sender: UIButton) {
        self.performSegue(withIdentifier: "infoSegue", sender: 1)
    }

    @IBAction func handleTouchGDE(_ sender: UIButton) {
        self.performSegue(withIdentifier: "infoSegue", sender: 2)
    }
    @IBOutlet weak var handleGDETouch: UIButton!
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSegue" {
            let tb = segue.destination as! UITabBarController
            if let nb = tb.childViewControllers[0] as? UINavigationController {
                if let vc = nb.childViewControllers[0] as? EnterpriseCollectionViewController {
                    vc.type = sender as! Int
                }
            }
        }
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! preHomeCollectionViewCell
        if indexPath.item == 1 {
            cell.backgroundImg.image = #imageLiteral(resourceName: "background-gde")
            cell.mainLogo.image = #imageLiteral(resourceName: "gde")
        }
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "infoSegue", sender: indexPath.item+1)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height = 0
        var width = 0
        //entra al if si el celular esta de lado o acostado
        if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown  || UIDevice.current.orientation == .faceDown || UIDevice.current.orientation == .faceUp{
            height = Int((self.collectionView?.frame.height)!/CGFloat(2))
            width = Int((self.collectionView?.frame.width)!)
        }else{
            height = Int((self.collectionView?.frame.height)!)
            width = Int((self.collectionView?.frame.width)!/CGFloat(2))
        }
        
        return CGSize(width: width, height: height)
    }
    func rotated() {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            collectionView?.reloadData()
        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            collectionView?.reloadData()
        }
        
    }


}
