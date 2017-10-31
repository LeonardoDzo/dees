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
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Group: Object, Codable {

    @objc dynamic var companyId: Int = -1
    @objc dynamic var id: Int = -1
    @objc dynamic var type: Int = -1
    @objc dynamic var userId: Int = -1
    var party = List<PartyMember>()
    var messages = List<MessageEntitie>()
    
    private enum CodingKeys: String, CodingKey {
        case companyId
        case type
        case id
        case userId
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
class PartyMember : Object, Codable {
    @objc dynamic var id: Int = -1
    @objc dynamic var name: String = ""
    @objc dynamic var lastname: String = ""
    @objc dynamic var dateIn: String = ""
    @objc dynamic var email: String = ""
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
   
}
