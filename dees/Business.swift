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
    static let kPhotoURl = "photoUrl"
    static let kColor = "color"
    static let kChilds = "children"
    static let kUsers = "users"
    
    
    var name: String?
    var phtoUrl: String?
    var color: String?
    var business : [Business]?
    var users = [User]()
    
    init(map: Mapper) throws {
        try self.name = map.from(Business.kName)
        self.phtoUrl = map.optionalFrom(Business.kPhotoURl)
        self.color = map.optionalFrom(Business.kColor)
        self.business = map.optionalFrom(Business.kChilds)
         try self.users = map.from(Business.kUsers)
        //try self.operative = map.from(Business.kOperative)
    }
}
