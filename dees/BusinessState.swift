//
//  BusinessState.swift
//  dees
//
//  Created by Leonardo Durazo on 08/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
struct BusinessState: StateType {
    var business = [Business]()
    var status: Result<Any>
}
