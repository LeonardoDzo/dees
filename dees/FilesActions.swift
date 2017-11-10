//
//  FilesActions.swift
//  dees
//
//  Created by Leonardo Durazo on 12/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
struct FileActions {
    struct get: Action {
        var eid: Int!
        var wid: Int!
        init(eid: Int, wid: Int? = nil) {
            self.eid = eid
            self.wid = wid
        }
    }
    struct delete: Action {
        var report : Report!
        var fid: Int!
    }
    
}




