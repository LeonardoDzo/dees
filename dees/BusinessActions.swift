//
//  BusinessReducer.swift
//  dees
//
//  Created by Leonardo Durazo on 08/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder

let businessActionTypeMap: TypeMap = [GetBusinessAction.type: GetBusinessAction.self]

struct GetBusinessAction: StandardActionConvertible {
    static let type = "GET_BUSINESS_ACTION"
    init() {
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: GetBusinessAction.type, payload: [:], isTypedAction: true)
    }
}
