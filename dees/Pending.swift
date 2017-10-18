//
//  Pending.swift
//  dees
//
//  Created by Leonardo Durazo on 17/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Mapper

struct Pending : Mappable {
    static let kwid = "idWeek"
    static let keid = "idCompany"
    static let kuid = "idUser"
    static let kusername = "user"
    
    var wid: Int!
    var eid: Int!
    var uid: Int!
    var username: String!
    
    init(map: Mapper) throws {
        try wid = map.from(Pending.kwid)
        try eid = map.from(Pending.keid)
        try uid = map.from(Pending.kuid)
        try username = map.from(Pending.kusername)
    }
}
