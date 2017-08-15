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
    
    var id: Int!
    var name: String?
    var phtoUrl: String?
    var color: String?
    var business = [Business]()
    var users = [User]()
    
    init(map: Mapper) throws {
        try self.id = map.from(Business.kId)
        try self.name = map.from(Business.kName)
        self.phtoUrl = map.optionalFrom(Business.kPhotoURl)
        self.color = map.optionalFrom(Business.kColor)
        self.business = map.optionalFrom(Business.kChilds) ?? []
        self.users = map.optionalFrom(Business.kUsers) ?? []
    }
    
    
}
