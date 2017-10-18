//
//  PendingsActions.swift
//  dees
//
//  Created by Leonardo Durazo on 17/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
typealias pActions = PendingsActions
struct PendingsActions {
    struct get: Action {
        var eid: Int!
        init(eid: Int) {
            self.eid = eid
        }
    }
}
