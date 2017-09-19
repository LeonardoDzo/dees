//
//  ReplyViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 28/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class ReplyViewController: UIViewController, UIGestureRecognizerDelegate {
   
    weak var delegate: reportDelegate!
    @IBOutlet weak var replyTxt: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleNavBarAndTab_1()
        let back = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.back))
        let add = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
        if store.state.userState.user.rol == .Superior {
            self.navigationItem.rightBarButtonItem = add
        }
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : Any]
        self.navigationItem.title = "Comentario para el Reply"

        self.navigationItem.leftBarButtonItem = back
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        replyTxt.text = delegate.report.replyTxt
        
    }
    
   
    func save() -> Void {
        delegate.report.replyTxt = replyTxt.text
        delegate.report.reply = true
        store.dispatch(rAction.Post(report: delegate.report))
        self.back()
    }

}
