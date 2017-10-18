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
    static let kstartDate = "startTime"
    static let kendDate = "endTime"
    
    var id: Int!
    var startDate: String!
    var endDate: String!
    
    init(map: Mapper) throws {
        try id = map.from(Week.kid)
        try startDate = map.from(Week.kstartDate)
        try endDate = map.from(Week.kendDate)
        
        startDate = startDate.components(separatedBy: "T").first
        endDate = endDate.components(separatedBy: "T").first
    }
    
    func getTitleOfWeek() -> String {
        return (Date(string:self.startDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear3))! + " al " + (Date(string:self.endDate, formatter: .yearMonthAndDay)?.string(with: .dayMonthAndYear2))!
    }
}
