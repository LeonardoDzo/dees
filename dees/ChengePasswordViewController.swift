//
//  ChengePasswordViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 15/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import Whisper
import ReSwift
import KDLoadingView
class ChengePasswordViewController: UIViewController {

    @IBOutlet weak var loading: KDLoadingView!
    @IBOutlet weak var oldPass: UITextField!
    @IBOutlet weak var newPass: UITextField!
    @IBOutlet weak var repeatPass: UITextField!
    @IBOutlet weak var cardView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = titleNavBarView(title: "Cambiar Contraseña", subtitle: "")
        setupBack()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        Whisper.hide(whisperFrom: navigationController!)
        store.unsubscribe(self)
    }
    

    @IBOutlet weak var handleChange: UIButton!
    
    @IBAction func handleChange(_ sender: UIButton) {
        guard let oldPassword = oldPass.text, !oldPassword.isEmpty else{
            let message = Message(title: "Favor de ingresar datos en el campo de la vieja contraseña")
            Whisper.show(whisper: message, to: navigationController!, action: .show)
            return
        }
        guard let newPassword = newPass.text, !newPassword.isEmpty else{
            let message = Message(title: "Favor de ingresar datos en el campo de nueva contraseña")
            Whisper.show(whisper: message, to: navigationController!, action: .show)
            return
        }
        guard let repeatPassword = repeatPass.text, !repeatPassword.isEmpty else{
            let message = Message(title: "Favor de ingresar datos en el campo de repetir contraseña")
            Whisper.show(whisper: message, to: navigationController!, action: .show)
            return
        }
        
        if repeatPassword == newPassword {
            store.dispatch(AuthActions.ChangePass(old: oldPassword, new: newPassword))
        }else{
            let message = Message(title: "Contraseñas no coinciden")
            Whisper.show(whisper: message, to: navigationController!, action: .present)
        }
        
    }
    

}
extension ChengePasswordViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = UserState
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self) {
            $0.select({
                s in s.userState
            })
        }
    }
    
    func newState(state: UserState) {
        loading.stopAnimating()
        switch state.status {
        case .loading:
            loading.isHidden = false
            loading.startAnimating()
            break
        case .finished:
            Whisper.show(whisper: messages.succesG, to: navigationController!, action: .present)
            break
        case .Failed(let m as String):
            Whisper.show(whisper: Message(title: m, backgroundColor: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)), to: navigationController!, action: .present)
            break
        default:
            break
        }
    }
}
