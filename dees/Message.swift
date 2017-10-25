//
//  Message.swift
//  dees
//
//  Created by Leonardo Durazo on 24/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import RealmSwift
class MessageEntitie: Object, Codable {
    @objc dynamic var createdAt: String = ""
    @objc dynamic var groupId: Int = 0
    @objc dynamic var id: Int = 0
    @objc dynamic var message: String = ""
    @objc dynamic var tags: String = ""
    @objc dynamic var userId: Int = -1
    @objc dynamic var weekId: Int = -1
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class GroupEntitie: Object, Codable {
    @objc dynamic var companyId: Int = -1
    @objc dynamic var id: Int = -1
    @objc dynamic var type: Int = 0
    @objc dynamic var userId: Int = -1
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    //let messages = List<MessageEntitie>()
}

