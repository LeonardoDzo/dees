//
//  UserAction.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder

let userActionTypeMap: TypeMap = [LogInAction.type: LogInAction.self,
                                  LogOutAction.type:LogOutAction.self,
                                  GetUserAction.type: GetUserAction.self]

struct LogInAction: StandardActionConvertible {
    static let type = "LOGIN_ACTION"
    var email: String!
    var password: String!
    init(password: String, email: String) {
        self.email = email
        self.password = password
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: LogInAction.type, payload: [:], isTypedAction: true)
    }
}
struct LogOutAction: StandardActionConvertible {
    static let type = "LOGOUT_ACTION"
    init() {}
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: LogOutAction.type, payload: [:], isTypedAction: true)
    }
}
struct GetUserAction: StandardActionConvertible {
    static let type = "USER_ACTION_GET"
    var uid: Int!
    var email: String!
    init(uid: Int) {
        self.uid = uid
    }
    init(email: String) {
        self.email = email
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: GetUserAction.type, payload: [:], isTypedAction: true)
    }
}
