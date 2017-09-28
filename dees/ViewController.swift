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
        
        store.dispatch(AuthActions.LogIn(password: pass, email: email))
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
    


}
extension ViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = UserState
    override func viewWillAppear(_ animated: Bool) {
        
        store.subscribe(self) {
            $0.select({
                s in s.userState
            })
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
            if u.permissions.contains(where: {$0.rid.rawValue >= 602}) {
                self.performSegue(withIdentifier: "preSegue", sender: u)
            }else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "tabBarController") as UIViewController
                present(vc, animated: true, completion: nil)
            }

            break
        case .Failed(let m as Murmur):
            // Show and hide a message after delay
            Whisper.show(whistle: m, action: .show(3))

            break
        default:
            break
        }
    }
}

