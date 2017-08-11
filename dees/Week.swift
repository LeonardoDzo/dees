//
//  week.swift
//  dees
//
//  Created by Leonardo Durazo on 10/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Mapper

struct Week : Mappable {
    static let kid = "id"
    static let kstartDate = "start_date"
    static let kendDate = "end_date"
    
    var id: Int!
    var startDate: String!
    var endDate: String!
    
    init(map: Mapper) throws {
        try id = map.from(Week.kid)
        try startDate = map.from(Week.kstartDate)
        try endDate = map.from(Week.kendDate)
    }
}
