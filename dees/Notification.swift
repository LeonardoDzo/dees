//
//  Notification.swift
//  familyOffice
//
//  Created by Leonardo Durazo on 1/02/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift
import UserNotifications

@objc enum Notification_Type: Int{
    case chat,
    report,
    none
    
    
}
@objcMembers
class NotificationModel : Object {
    typealias not = NotificationModel
    
    dynamic var id: String = ""
    dynamic var title: String = ""
    dynamic var timestamp: Int = 0
    dynamic var value: String = ""
    dynamic var type: Notification_Type = .none
    dynamic var body = ""
    dynamic var seen = false
    dynamic var lastupdated = 0
    dynamic var mydata: String = ""
    //EN REPORT EL ORDEN ES: CompanyId, UserId, WeekId
    convenience required init(notifiaction: UNNotification) {
        self.init()
        let content = notifiaction.request.content
        print(content.userInfo)
        self.id = notifiaction.request.identifier
        
        
        self.title = content.title
        self.body = content.body
        self.timestamp = notifiaction.date.toMillis()
        if let lockey = content.userInfo["loc-key"] as? NSArray {
            if lockey.count == 2 {
                self.type = .chat
            }else{
                self.type = .report
            }
            lockey.forEach({ (value) in
                self.mydata += String(describing: value) + ","
            })
        }
    }
    convenience required init(dic: [AnyHashable: Any]) {
        self.init()
        if let aps = dic["aps"] as? NSDictionary, let content =  aps["alert"] as? NSDictionary{
            if let id = dic["gcm.message_id"] as? String {
                self.id =  id
            }
            
            
            if let title = content["title"] as? String {
                self.title = title
            }
            if let body = content["body"] as? String {
                self.body = body
            }
            if let lockey = content["loc-key"] as? NSArray {
                if lockey.count == 2 {
                    self.type = .chat
                }else{
                    self.type = .report
                }
                lockey.forEach({ (value) in
                    self.mydata += String(describing: value) + ","
                })
            }
            self.timestamp = Date().toMillis()
        }
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }

    
}

protocol NotificationBindible: AnyObject {
    var notification : NotificationModel! {get set}
    var titleLbl: UILabel! {get}
    var bodyLbl: UILabel! {get}
    var dateLbl: UILabel! {get}
    var bodyTxtV: UITextView! {get}
    var typeImg: UIImageViewX! {get}
}
extension NotificationBindible {
    var titleLbl: UILabel! {return nil}
    var dateLbl: UILabel! {return nil}
    var bodyLbl: UILabel! {return nil}
    var bodyTxtV: UITextView! {return nil}
    func bind(_ not: NotificationModel) -> Void {
        self.notification = not
        bind()
    }
    func bind() -> Void {
        guard let notification = self.notification else {
            return
        }
        if let titleLbl = self.titleLbl {
            titleLbl.text = notification.title
        }
        if let bodyLbl = self.bodyLbl {
            bodyLbl.text = notification.body
        }
        if let bodyTxtV = self.bodyTxtV {
            bodyTxtV.text = notification.body
        }
        if let dateLbl = self.dateLbl {
            if let date = Date(notification.timestamp) {
                if date.isToday() {
                    dateLbl.text = date.string(with: .hourAndMin)
                }else if date.isYesterday() {
                    dateLbl.text = "Ayer"
                }else{
                    dateLbl.text = date.string(with: .ddMMMyyyy)
                }
            }
            
            
        }
    
    }
}

