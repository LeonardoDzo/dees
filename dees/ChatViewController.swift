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
    var type : TYPE_ON_REPORT!
    var eid : Int!
    var report : Report?
    var user  : User!
    func getEnterprise() -> Business? {
        var enterprise : Business!
        if store.state.userState.user.isDirectorCeo() {
            store.state.businessState.getEnterprise(id: eid, handler: { b in
                enterprise = b
            })
        }else{
            enterprise = store.state.userState.user.bussiness.first(where: {$0.id == eid})
           
        }
         return enterprise
    }
    
}
struct message_section {
    var day: String!
    var messages = [MessageEntitie]()
}

class ChatViewController: UIViewController {
    @IBOutlet weak var weekLbl: UIButton!
    var conf : configuration!
    var group: Results<Group>!
    let notificationCenter = NotificationCenter.default
    var messages_group : Results<MessageEntitie>!
    var notificationToken: NotificationToken? = nil
    var isFiltering = false
    var section_Messages = [message_section]()
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightLayoutView: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var bottomLayout: NSLayoutConstraint!
    
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
        self.navigationController?.delegate = self
        self.setupBack()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let titleWeek = store.state.weekState.getWeeks().first(where: {$0.id == conf.wid})?.getTitleOfWeek() {
             weekLbl.setTitle("Semana \(titleWeek)", for: .normal)
        }
       
        let user = conf.user
        var name = conf.type.getString()
        let enterprise = conf.getEnterprise()
        if store.state.userState.user.isDirectorCeo() {
            if user == nil {
                name.append(enterprise?.users.first(where: {$0.id != store.state.userState.user.id})?.name ?? "Sin nombre")
            }else{
                name.append((user?.name)!)
            }
        }else{
            name.append(store.state.userState.user.name!)
        }
        
        
        
        self.navigationItem.titleView = titleNavBarView(title: (enterprise?.name!)!, subtitle:  name)
        
 
        store.subscribe(self) {
            $0.select({ (state)  in
                state.groupState
            })
        }
        
        store.dispatch(GroupsAction.GroupIn(m: _requestMessage(eid: conf.eid, wid: conf.wid, uid: conf.uid, type:  conf.type, message: "")))
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: isFiltering ? #imageLiteral(resourceName: "filtered-Filled") : #imageLiteral(resourceName: "filter"), style: .plain, target: self, action: #selector(self.filtered))
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }
    @objc func filtered() -> Void {
        isFiltering = !isFiltering
        isFiltered()
        self.tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        store.unsubscribe(self)
        store.state.groupState.currentGroup = .none
    }
    override func viewDidAppear(_ animated: Bool) {
        self.bottomLayout.constant = 0
        self.loadViewIfNeeded()
        
    }
    @IBAction func handleSendMessage(_ sender: UIButton) {
       
        if group != nil, let g = group.first?._party.first(where: {$0.id != store.state.userState.user.id}) {
            conf.uid = g.id
        }
        let m = _requestMessage(eid: conf.eid, wid: conf.wid, uid: conf.uid, type: conf.type, message: messageTxtView.text)
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
    
    @IBAction func handleChangeWeek(_ sender: UIButton) {
        self.pushToView(view: .weeksView)
    }
    
    func isFiltered() -> Void {
        guard  group != nil  else {
            return
        }
        print("Grupo", group.first?._party ?? "Nada")
        messages_group = isFiltering ? group.first?._messages.filter("weekId = %@", conf.wid) : group.first?._messages.sorted(byKeyPath: "timestamp")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: isFiltering ? #imageLiteral(resourceName: "filtered-Filled") : #imageLiteral(resourceName: "filter"), style: .plain, target: self, action: #selector(self.filtered))
        let backgroundImage = #imageLiteral(resourceName: "nomessages")
        if messages_group.count == 0 {
            let imageView = UIImageView(image: backgroundImage)
            imageView.contentMode = .scaleAspectFit
            self.tableView.backgroundView = imageView
        }else{
            self.tableView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        getSections()
        
    }
    func getSections() -> Void {
        section_Messages.removeAll()
        
        messages_group.forEach { (m) in
            let date = Date(timeIntervalSince1970: TimeInterval(m.timestamp/1000))
            if let index = section_Messages.index(where: {$0.day == date.string(with: .dayMonthAndYear2)}) {
                section_Messages[index].messages.append(m)
            }else{
                section_Messages.append(message_section(day: date.string(with: .dayMonthAndYear2), messages: [m]))
            }
        }
    }
    
    
}

extension ChatViewController : UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return section_Messages.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  section_Messages[section].messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message =  section_Messages[indexPath.section].messages[indexPath.row]
       
        let cell = tableView.dequeueReusableCell(withIdentifier: message.userId == store.state.userState.user.id ? "myCell" : "uCell" , for: indexPath) as! MyMessageTableViewCell
        cell.bind(by: message, group: group.first)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message =  section_Messages[indexPath.section].messages[indexPath.row]
        let size  = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: (message.message)).boundingRect(with: size, options: options, attributes:nil, context: nil)
        return estimatedFrame.height + 60
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        self.bottomLayout.constant = 0
        self.view.setNeedsDisplay()
        self.view.layoutIfNeeded()
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabelX()
        label.frame = CGRect(x: self.view.frame.width/2, y: 0, width: 40, height: 30)
        label.cornerRadius = 6
        
        label.text = section_Messages[section].day
        label.textAlignment = .center
        label.sizeToFit()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.562687286)
        return label
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    

    
}
