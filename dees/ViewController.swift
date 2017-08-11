//
//  ViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import EZLoadingActivity
class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var emailLbl: UITextField!
    @IBOutlet weak var passwordLbl: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func handleLogin(_ sender: UIButton) {
        
        guard let email = emailLbl.text, !email.isEmpty else {
            return
        }
        guard let pass = passwordLbl.text, !pass.isEmpty else {
            return
        }
        EZLoadingActivity.show("Logeando...", disableUI: false)
        store.dispatch(LogInAction(password: pass, email: email))
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }


}
extension ViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = UserState
    override func viewWillAppear(_ animated: Bool) {
        
        store.subscribe(self) {
            state in
            state.user
        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    func newState(state: UserState) {
        switch state.status {
        case .loading:
            break
        case .Finished(let u as User):
            EZLoadingActivity.hide(true, animated: true)
            self.performSegue(withIdentifier: "mainSegue", sender: u)
            break
        default:
            break
        }
    }
}

