//
//  GroupEntitie.swift
//  dees
//
//  Created by Leonardo Durazo on 10/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift

class Group: Object, Codable {
    
    @objc dynamic var companyId: Int = -1
    @objc dynamic var id: Int = -1
    @objc dynamic var type: Int = -1
    @objc dynamic var userId: Int = -1
    var _party = List<PartyMember>()
    var party = [PartyMember]()
    var _messages = List<MessageEntitie>()
    var messages = [MessageEntitie]()
    private enum CodingKeys: String, CodingKey {
        case companyId
        case type
        case id
        case userId
        case party
        case messages
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    override static func ignoredProperties() -> [String] {
        return ["party","messages"]
    }
}
class PartyMember : Object, Codable {
    @objc dynamic var id: Int = -1
    @objc dynamic var name: String = ""
    @objc dynamic var lastname: String = ""
    @objc dynamic var dateIn: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var timestamp : Int = -1
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

struct UserCD : Codable{
    var id: Int!
    var name: String!
    var lastname: String!
    var email: String!
}
