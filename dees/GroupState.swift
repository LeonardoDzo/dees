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
    
}

