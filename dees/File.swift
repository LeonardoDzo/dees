//
//  File.swift
//  dees
//
//  Created by Leonardo Durazo on 17/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Mapper

struct File: Mappable {
    static let kid = "id"
    static let kidFormat = "reportId"
    static let kname = "name"
    static let kpath = "uri"
    static let kextension = "extension"
    static let kmime = "mime"
    static let ktype = "type"
    
    var id : Int!
    var fid: Int!
    var name: String?
    var ext: String?
    var mime: String?
    var type: Int?
    var path: String?
    
    init(map: Mapper) throws {
        try id = map.from(File.kid)
        try fid = map.from(File.kidFormat)
        name = map.optionalFrom(File.kname)
        ext = map.optionalFrom(File.kextension)
        mime = map.optionalFrom(File.kmime)
        type = map.optionalFrom(File.ktype)
        path = map.optionalFrom(File.kpath)
    }
}
