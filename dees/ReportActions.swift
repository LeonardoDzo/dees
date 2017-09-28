//
//  ReportActions.swift
//  dees
//
//  Created by Leonardo Durazo on 10/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

typealias wAction = WeeksAction
typealias rAction = ReportsAction

struct ReportsAction {
    struct Get : Action {
        var eid: Int!
        var wid: Int!
        var uid: Int!
        init(eid: Int? = nil, wid: Int, uid: Int? = nil) {
            self.eid = eid
            self.wid = wid
            self.uid = uid
        }
    }
    
    struct Post: Action {
        var report: Report!
        init(report: Report) {
            self.report = report
        }
    }
}

struct WeeksAction {
    struct Get: Action {
        init() {
        }
    }
}
