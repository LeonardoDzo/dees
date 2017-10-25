//
//  ChatViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 23/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    var enterprise: Business!
    var user: User!
    var file_type: Int!
    var report: Report!
    let notificationCenter = NotificationCenter.default
    
    @IBOutlet weak var messageTxtView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleNavBarAndTab_1()
        self.tabBarController?.tabBar.isHidden = true
        notificationCenter.addObserver(self, selector: #selector(AllReportsTableViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(AllReportsTableViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
         self.hideKeyboardWhenTappedAround()
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var name = file_type != 0 ? "Financiero de " : "Operativo de "
        name.append(user.name!)
        let objects  = realm.getObjects(type: MessageEntitie.self)
        objects?.forEach({ element in
            if let message = element as? MessageEntitie {
                // Do whatever you like with 'person' object
                print(message)
            }
        })
        self.navigationItem.titleView = titleNavBarView(title: enterprise.name!, subtitle: name)
    }
    
    @IBAction func handleSendMessage(_ sender: UIButton) {
        let m = _requestMessage(eid: self.enterprise.id, wid: self.report.wid, uid: self.report.uid, type: TYPE_ON_REPORT(rawValue: self.file_type), message: messageTxtView.text)
        store.dispatch(UsersAction.SendMessage(m: m))
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
extension ChatViewController: UITextViewDelegate {
    func adjustUITextViewHeight(arg : UITextView)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()  
    }
}
