//
//  Message.swift
//  dees
//
//  Created by Leonardo Durazo on 24/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift
import Mapper

class MessageEntitie: Object, Codable {
    @objc dynamic var createdAt: String = ""
    @objc dynamic  var timestamp : Int = 0
    @objc dynamic var groupId: Int = 0
    @objc dynamic var id: Int = 0
    @objc dynamic var message: String = ""
    @objc dynamic var tags: String = ""
    @objc dynamic var userId: Int = -1
    @objc dynamic var weekId: Int = -1
    
    
    private enum CodingKeys: String, CodingKey {
        case createdAt
        case groupId
        case id
        case message
        case tags
        case userId
        case weekId
        case timestamp
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

protocol MessageBindible: AnyObject {
    var message: MessageEntitie! {get set}
    var group : Group? {get set}
    var nameLbl: UILabel! {get}
    var weekLbl: UILabel! {get}
    var hourLbl: UILabel! {get}
    var messageTxt: UITextView! {get}
}
extension MessageBindible {
    var nameLbl: UILabel! {return nil}
    var weekLbl: UILabel! {return nil}
    var hourLbl: UILabel! {return nil}
    var messageTxt: UITextView! {return nil}
    
    func bind(by message: MessageEntitie, group: Group? = nil) {
        self.message = message
        self.group = group
        self.bind()
    }
    func bind() -> Void {
        guard let message = message else {
            return
        }
        
        if let messageTxt = self.messageTxt {
            messageTxt.text = self.message.message
        }
        if let weekLbl = self.weekLbl {
            if let week = store.state.weekState.getWeeks().first(where: {$0.id == message.weekId}) {
                weekLbl.text = "Sem. " + week.getTitleOfWeek()
            }
        }
        if let hourLbl = self.hourLbl {
            hourLbl.text = Date(timeIntervalSince1970: TimeInterval(message.timestamp/1000)).string(with: .hourAndMin)
            hourLbl.sizeToFit()
        }
        if let nameLbl = self.nameLbl {
            if let own =  self.group?._party.first(where: {$0.id == message.userId}) {
                nameLbl.text = own.name + " " + own.lastname
            }
        }
    }
}


