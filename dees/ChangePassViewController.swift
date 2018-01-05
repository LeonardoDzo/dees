//
//  ChangePassViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 04/01/18.
//  Copyright © 2018 Leonardo Durazo. All rights reserved.
//

import UIKit
import Whisper
import ReSwift
import KDLoadingView

class ChangePassViewController: UIViewController, UIGestureRecognizerDelegate {
    lazy var loading: KDLoadingView = {
        let view = KDLoadingView(frame: CGRect(origin: CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2), size: CGSize(width: 100, height: 100)))
        view.firstColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        view.secondColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        view.hidesWhenStopped = true
        return view
    }()
    @IBOutlet var passBtns: [UITextFieldX]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func handeChangePass(_ sender: UIButtonX) {
        passBtns.enumerated().forEach { (index,btn) in
            if (btn.text?.isEmpty)! {
                Whisper.show(whistle: messages.error._09, action: .show(3))
                return
            }
            if let text = btn.text, text.count < 6 {
                Whisper.show(whistle: messages.error._08, action: .show(3))
                return
            }
            if let text = btn.text, text.count > 16 {
                Whisper.show(whistle: messages.error._11, action: .show(3))
                return
            }
            if index == 2 {
                if passBtns[1].text != btn.text {
                    
                    Whisper.show(whistle: messages.error._07, action: .show(3))
                    return
                }else{
                    store.dispatch(AuthActions.ChangePass(old: passBtns[0].text!, new: passBtns[1].text!))
                    
                }
            }
        }
    }
    

}
extension ChangePassViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = UserState
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        store.subscribe(self) {
            $0.select({ (s)  in
                s.userState
            })
        }
    }
    func newState(state: UserState) {
        loading.stopAnimating()
        self.view.isUserInteractionEnabled = true
        switch state.status {
            
        case .loading:
            loading.isHidden = false
            loading.startAnimating()
            self.view.isUserInteractionEnabled = false
            break
        case .finished:
            Whisper.show(whistle: messages.success._00, action: .show(3))
            break
        case .Failed(let mur as Murmur):
            Whisper.show(whistle: mur, action: .show(3))
            break
        default:
            break
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
}
