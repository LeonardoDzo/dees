//
//  PendingsState.swift
//  dees
//
//  Created by Leonardo Durazo on 17/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct PendingsState: StateType {
    var pendings: Result<Any> = .loading
    
    func getPendigs() -> [Pending] {
        switch self.pendings {
        case .Finished(let p as [Pending]):
            return p
        default:
            return []
        }
    }
}
