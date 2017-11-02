//
//  ChatViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 23/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import RealmSwift

struct configuration{
    var uid : Int!
    var wid : Int!
    var type : Int!
    var eid : Int!
    var files = [File]()
    var user  : User!
    func getEnterprise() -> Business? {
        return store.state.businessState.getEnterprise(id: eid) ?? store.state.userState.user.bussiness.first(where: {$0.id == eid})
    }
    
}


class ChatViewController: UIViewController {
    var conf : configuration!
    var group: Results<Group>!
    let notificationCenter = NotificationCenter.default
    var messages_group : Results<MessageEntitie>!
    var notificationToken: NotificationToken? = nil
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightLayoutView: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.styleNavBarAndTab_1()
        self.tabBarController?.tabBar.isHidden = true
        notificationCenter.addObserver(self, selector: #selector(AllReportsTableViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(AllReportsTableViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
         self.hideKeyboardWhenTappedAround()
        messageTxtView.delegate = self
        sendBtn.imageView?.image? =  (sendBtn.imageView?.image?.maskWithColor(color: #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)))!
        addBtn.imageView?.image? = (addBtn.imageView?.image?.maskWithColor(color: #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)))!
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
        let user = conf.user
        var name = conf.type != 0 ? "Financiero de " : "Operativo de "
        if store.state.userState.user.isDirectorCeo() {
            name.append((user?.name)!)
        }else{
            name.append(store.state.userState.user.name!)
        }
        
        
        if let enterprise = conf.getEnterprise() {
            self.navigationItem.titleView = titleNavBarView(title: enterprise.name!, subtitle:  name)
        }
 
        store.subscribe(self) {
            $0.select({ (state)  in
                state.groupState
            })
        }
        store.dispatch(GroupsAction.GroupIn(m: _requestMessage(eid: conf.eid, wid: conf.wid, uid: conf.uid, type: TYPE_ON_REPORT(rawValue: conf.type), message: "")))
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        store.unsubscribe(self)
    }
    
    @IBAction func handleSendMessage(_ sender: UIButton) {
        let m = _requestMessage(eid: conf.eid, wid: conf.wid, uid: conf.uid, type: TYPE_ON_REPORT(rawValue: conf.type), message: messageTxtView.text)
        messageTxtView.text.removeAll()
        heightLayoutView.constant = 47
        store.dispatch(GroupsAction.SendMessage(m: m))
    }
    deinit {
        notificationToken?.invalidate()
        group = nil
        conf = nil
        store.state.groupState.currentGroup = .none
    }
    
    
    
}

extension ChatViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if group != nil , let m = group.first?.messages {
            print("Messages: ",m)
        }
        print(self.group)
       let count = group != nil ? group.first!.messages.count  : 0
         return  count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let message =  self.group.first?.messages[indexPath.row] else {
             let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyMessageTableViewCell
             cell.messageTxt.text = "HUBO UN ERRIR"
            return cell
        }
       
        let own =  self.group.first?._party.first(where: {$0.id == message.userId})
        let cell = tableView.dequeueReusableCell(withIdentifier: message.userId == store.state.userState.user.id ? "myCell" : "uCell" , for: indexPath) as! MyMessageTableViewCell
        if let week = store.state.weekState.getWeeks().first(where: {$0.id == message.weekId}) {
            cell.weekLbl.text = "Sem. " + week.getTitleOfWeek()
        }
        cell.messageTxt.text = message.message
        cell.hourLbl.text = Date(timeIntervalSince1970: TimeInterval(message.timestamp/1000)).string(with: .hourAndMin)
        cell.hourLbl.sizeToFit()
        if cell.nameLbl != nil {
            cell.nameLbl.text! = (own?.name)! + " " + (own?.lastname)!
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let message = group.first?.messages[indexPath.row] else {
            return 0
        }
        let size  = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: (message.message)).boundingRect(with: size, options: options, attributes:nil, context: nil)
        return estimatedFrame.height + 60
    }
    
    
}
