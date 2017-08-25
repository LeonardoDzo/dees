//
//  PreHomeViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 15/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class PreHomeViewController: UIViewController {

    @IBOutlet weak var oppesa: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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


}
