//
//  UserSatate.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
struct UserState: StateType {
    var user: User!
    var status: Result<Any>
}
