//
//  Persmission.swift
//  dees
//
//  Created by Leonardo Durazo on 26/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Mapper
struct Permission : Mappable {
    
    typealias p = Permission
    static let kcompanyId = "companyId"
    static let kroleId = "roleId"
    
    var cid : Int!
    var rid : Rol!
    
    init(map: Mapper) throws {
        try cid = map.from(p.kcompanyId)
        try self.rid =  Rol(rawValue: map.from(p.kroleId)) ?? Rol(rawValue: 1000)
    }
}
