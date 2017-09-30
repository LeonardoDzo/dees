//
//  EnterpriseViewViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 22/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import Whisper

class EnterpriseViewViewController: UIViewController {
    var enterprise: Business!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var colorLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = titleNavBarView(title: "Perfil", subtitle: "")
        setupBack()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        store.subscribe(self) {
            $0.select({
                s in s.businessState
            })
        }
    }
    func bind() -> Void {
        if enterprise == nil {
            self.dismiss(animated: true, completion: nil)
        }
        nameLbl.text = enterprise.name
        if enterprise.color != nil {
            colorLbl.backgroundColor = UIColor(hexString: "#\(enterprise.color!)ff")
        }
        if enterprise.business.count > 0 {
            self.editBtn.isHidden = true
        }else if store.state.userState.user.permissions.contains(where: {$0.rid.rawValue >= 602})  {
            editBtn.isHidden = true
        }else{
            editBtn.isHidden = false
        }
    }
    
    @IBAction func handleEdit(_ sender: Any) {
        let alertController = UIAlertController(title: "Cambiar Nombre", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            
            guard let name = firstTextField.text, !name.isEmpty, (firstTextField.text?.characters.count)! > 4 else {
                return
            }
            self.enterprise.name = name
            store.dispatch(baction.Put(e: self.enterprise))
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = self.enterprise.name
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
}
extension EnterpriseViewViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return enterprise.users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let u = enterprise.users[indexPath.row]
        cell.textLabel?.text = u.name
        cell.detailTextLabel?.text = u.email
        return cell
    }
}
extension EnterpriseViewViewController: StoreSubscriber {
    
    typealias StoreSubscriberStateType = BusinessState
    
    func newState(state: BusinessState) {
        switch state.status {
        case .loading:
            break
        case .finished:
            Whisper.show(whistle: messages.success._00, action: .show(2.5))
            break
        case .failed:
            Whisper.show(whistle: messages.error._00, action: .show(2.5))
            break
        default:
            state.business.enumerated().forEach({
                index, b in
                if b.id == enterprise?.id {
                    enterprise = store.state.businessState.business[index]
                    return
                }else{
                    b.business.enumerated().forEach({
                        i2, b2 in
                        if b2.id == enterprise?.id {
                            enterprise = store.state.businessState.business[index].business[i2]
                            return
                        }
                    })
                }
            })
            bind()
            break
        }
        
    }
    
    
}
