//
//  chatView_StoreSubscriber.swift
//  dees
//
//  Created by Leonardo Durazo on 26/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import RealmSwift

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        
        return array
    }
}


extension ChatViewController : StoreSubscriber {
    typealias StoreSubscriberStateType = GroupState
    
    func newState(state: GroupState) {
        
        
        switch state.currentGroup {
            
        case .loading:
            break
        case .Finished(let g):
            self.group = realm.realm.objects(Group.self).filter("id = %@", g.id)
            notificationToken = notificationSubscription(group: self.group)
            break
        default:
            break
        }
    }
    
    func notificationSubscription(group: Results<Group>) -> NotificationToken {
        return group.observe {[weak self] (changes) in
           self?.updateUI(changes: changes)
        }
    }
    func updateUI(changes: RealmCollectionChange<Results<Group>>) -> Void  {
        switch changes {
        case .initial:
            
            tableView.reloadData()
        case .update(_, _, _, _):
            // Query results have changed, so apply them to the UITableView
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: (self.group.first?._messages.count)!-1, section: 0)], with: .automatic)
           
            self.tableView.endUpdates()
             self.tableView.scrollToRow(at: IndexPath(row: (self.group.first?._messages.count)!-1, section: 0), at: .bottom, animated: true)
        case .error:
            // handle error
            ()
        }
        if self.group.first != nil, (self.group.first?._messages.count)! > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: (self.group.first?._messages.count)!-1, section: 0), at: .bottom, animated: true)
        }
    }
    

    
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let val = heightLayoutView.constant - textView.frame.size.height
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        heightLayoutView.constant = CGFloat(textView.frame.height + val)
    }
}

