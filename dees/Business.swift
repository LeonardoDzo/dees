//
//  Business.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Mapper
struct Business : Mappable {
  

    static let kName = "name"
    static let kPhotoURl = "photo"
    static let kColor = "color"
    static let kChilds = "children"
    static let kUsers = "users"
    static let kId = "id"
    static let kType = "type"
    static let kExt = "extend"
    
    var id: Int!
    var name: String?
    var phtoUrl: String?
    var color: String?
    var business = [Business]()
    var type : Int?
    var users = [User]()
    var ext: Int?
    init() {
        name = ""
        phtoUrl = ""
        color = ""
        type = 0
    }

    init(map: Mapper) throws {
        try self.id = map.from(Business.kId)
        try self.name = map.from(Business.kName)
        self.phtoUrl = map.optionalFrom(Business.kPhotoURl)
        self.color = map.optionalFrom(Business.kColor)
        self.type = map.optionalFrom(Business.kType) ?? 0
        self.business = map.optionalFrom(Business.kChilds) ?? []
        self.users = map.optionalFrom(Business.kUsers) ?? []
        self.ext = map.optionalFrom(Business.kExt) ?? nil
    }
    
    func toDictionary() -> NSDictionary {
        return [
            Business.kName : self.name ?? "",
            Business.kPhotoURl : self.phtoUrl ?? "",
            Business.kColor : self.color ?? "",
            Business.kType : self.type ?? 1,
            Business.kUsers : self.users.map({$0.toDictionary()}),
            Business.kChilds: self.business.map({$0.toDictionary()}),
            Business.kExt : self.ext ?? nil
        ]
    }
    
    
}
