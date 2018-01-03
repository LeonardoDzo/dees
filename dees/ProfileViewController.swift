//
//  ProfileViewController.swift
//  dees
//
//  Created by Leonardo Durazo on 07/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
import ReSwift
import UserNotifications
class ProfileViewController: UIViewController, UserBindible {
    var user: User!
    var previousScrollOffset: CGFloat = 0;
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var signout: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var profile: UIImageViewX!
    
    @IBOutlet weak var changePass: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgrounView: UIView!
    
    let maxHeaderHeight: CGFloat = 143;
    let minHeaderHeight: CGFloat = 44;
    let center = UNUserNotificationCenter.current()
    var notifications  = [UNNotificationRequest]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.styleNavBarAndTab_1()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        let view = UIView(frame: self.tableView.frame)
        let label = UILabel()
        label.center = view.center
        label.text = "No hay notificaciones"
        view.addSubview(label)
        self.tableView.backgroundView = view
        
        self.backgrounView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background-opessa"))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: Any) {
        store.dispatch(AuthActions.LogOut())
    }

}

extension ProfileViewController: StoreSubscriber{
    typealias StoreSubscriberStateType = UserState
    
    override func viewWillAppear(_ animated: Bool) {
        self.user = store.state.userState.user
        self.bind()
        self.headerHeightConstraint.constant = self.maxHeaderHeight
        self.titleLbl.text = self.nameLbl.text
        self.navigationController?.isNavigationBarHidden = true
        store.subscribe(self){
            $0.select( {
                s in s.userState
            })
        }
        center.getPendingNotificationRequests(completionHandler: { requests in
            self.notifications = requests
        })
        
        updateHeader()
        self.tableView.reloadData()
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
extension ProfileViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let not = notifications[indexPath.row]
        cell.textLabel?.text = not.content.title
        cell.detailTextLabel?.text = not.content.body
        return cell
    }
}
extension ProfileViewController : UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        if canAnimateHeader(scrollView)  {
            let val : Int = tableView.visibleCells[0].tag
            // Calculate new header height
            var newHeight = self.headerHeightConstraint.constant
            if isScrollingDown{
                newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
            } else if isScrollingUp, val == 0{
                newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
            }
            
            // Header needs to animate
            if newHeight != self.headerHeightConstraint.constant, newHeight < 142{
                self.headerHeightConstraint.constant = newHeight
                self.updateHeader()
                self.setScrollPosition(self.previousScrollOffset)
            }
            
            self.previousScrollOffset = scrollView.contentOffset.y
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStopScrolling()
        }
    }
    
    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)
        
        if self.headerHeightConstraint.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }
    
    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        // Calculate the size of the scrollView when header is collapsed
        let scrollViewMaxHeight = scrollView.frame.height + self.headerHeightConstraint.constant  - minHeaderHeight
        
        // Make sure that when header is collapsed, there is still room to scroll
        return scrollView.contentSize.height > scrollViewMaxHeight
    }
    
    func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.minHeaderHeight

            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            self.headerHeightConstraint.constant = self.maxHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }
    
    func setScrollPosition(_ position: CGFloat) {
        self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: position)
    }
    
    func updateHeader() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let openAmount = self.headerHeightConstraint.constant - self.minHeaderHeight
        let percentage = openAmount / range
        
        self.titleLbl.alpha = 1 - percentage
        self.profile.alpha = percentage
        self.nameLbl.alpha = percentage
        self.emailLbl.alpha = percentage
        //self.changePass.alpha = percentage
    }
}
