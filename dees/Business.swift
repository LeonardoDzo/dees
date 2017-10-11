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
    static let kExt = "parentId"
    
    var id: Int!
    var name: String?
    var phtoUrl: String?
    var color: String?
    var business = [Business]()
    var type : Int?
    var users = [User]()
    var parentId: Int?
    init() {
        name = ""
        phtoUrl = ""
        color = ""
        type = 0
    }

    init(map: Mapper) throws {
        if let dic : NSDictionary = map.optionalFrom("company") {
            try self.myInfo(map: Mapper(JSON: dic))
           
            self.users = map.optionalFrom(Business.kUsers) ?? []

        }else{
            try self.myInfo(map:  map)
        }
       
    }
    
    mutating func myInfo(map: Mapper) throws -> Void {
        try self.id = map.from(Business.kId)
        try self.name = map.from(Business.kName)
        self.phtoUrl = map.optionalFrom(Business.kPhotoURl)
        self.color = map.optionalFrom(Business.kColor)
        
        self.parentId = map.optionalFrom(Business.kExt) ?? nil
    }
    
    func toDictionary() -> NSDictionary {
        return [
            Business.kName : self.name ?? "",
            Business.kPhotoURl : self.phtoUrl ?? "",
            Business.kColor : self.color ?? "",
            Business.kUsers : self.users.map({$0.toDictionary()}),
            Business.kChilds: self.business.map({$0.toDictionary()}),
            Business.kExt : self.parentId ?? ""
        ]
    }
    
    
}
