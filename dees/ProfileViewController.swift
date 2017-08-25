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
        UIApplication.shared.statusBarStyle = .lightContent
        profileView.formatView()
        profileImg.profileUser()
        //profileView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        //profileView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.07843137255, green: 0.1019607843, blue: 0.1647058824, alpha: 1)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.1215686275, green: 0.6901960784, blue: 0.9882352941, alpha: 1)
        self.tabBarController?.tabBar.barTintColor = #colorLiteral(red: 0.07843137255, green: 0.1019607843, blue: 0.1647058824, alpha: 1)
        self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: Any) {
        store.dispatch(LogOutAction())
    }
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
