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
       
        let section = section_Messages.count
        isFiltered()
        switch changes {
        case .initial:
            tableView.reloadData()
            if section_Messages.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: ((section_Messages.last?.messages.count)!-1), section: section_Messages.count-1), at: .bottom, animated: true)
            }
        case .update(_, _, _, _):
            // Query results have changed, so apply them to the UITableView
           
            if section_Messages.count <= 1 {
                tableView.reloadData()
                
            }else{
                 self.tableView.beginUpdates()
                if self.section_Messages.count > section  {
                    self.tableView.insertSections(IndexSet(integer: section_Messages.count - section), with: .automatic)
                }else{
                    self.tableView.insertRows(at: [IndexPath(row: ((section_Messages.last?.messages.count)!-1), section: section_Messages.count-1)], with: .automatic)
                    
                }
                if section_Messages.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: ((section_Messages.last?.messages.count)!-1), section: section_Messages.count-1), at: .bottom, animated: true)
                }
                self.tableView.endUpdates()
            }
            
           
           
        case .error:
            ()
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

