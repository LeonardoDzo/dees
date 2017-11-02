//
//  GroupState.swift
//  dees
//
//  Created by Leonardo Durazo on 26/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct GroupState: StateType {
    var groups : Result<Any> = .loading
    var currentGroup : Result<Group> = .loading
    
    func isCurrentGroup(id: Int) -> Bool {
        switch currentGroup {
        case .Finished(let t):
            if t.id == id {
                return true
            }
            return false
        default:
            return false
        }
    }
}

