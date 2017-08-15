//
//  ViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import KDLoadingView
import Whisper
class ViewController: UIViewController, UIGestureRecognizerDelegate {
   
    
    @IBOutlet weak var loading: KDLoadingView!
    @IBOutlet weak var emailLbl: UITextField!
    @IBOutlet weak var passwordLbl: UITextField!
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        loading.hidesWhenStopped = true
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
        loading.stopAnimating()
        
        switch state.status {
        case .loading:
            loading.isHidden = false
            loading.startAnimating()

            break
        case .Finished(let u as User):

            self.performSegue(withIdentifier: "mainSegue", sender: u)
            break
        case .Failed(let m as Murmur):
            // Show and hide a message after delay
            Whisper.show(whistle: m, action: .show(0.5))

            break
        default:
            break
        }
    }
}

