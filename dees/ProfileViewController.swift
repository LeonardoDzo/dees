//
//  ProfileViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 07/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift

class ProfileViewController: UIViewController, UserBindible {
    var user: User!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileView: UIView!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.formatView()
        profileImg.profileUser()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: Any) {
        store.dispatch(LogOutAction())
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileViewController: StoreSubscriber{
    typealias StoreSubscriberStateType = UserState
    
    override func viewWillAppear(_ animated: Bool) {
        self.user = store.state.userState.user
        self.bind()
        
        store.subscribe(self){
            state in
            state.userState
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.unsubscribe(self)
    }
    
    func newState(state: UserState) {
        
        switch state.status {
        case .Finished(let s as String):
            if s == "logout"{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "startView") as UIViewController
                present(vc, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
}
