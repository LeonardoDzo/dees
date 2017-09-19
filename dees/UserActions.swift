//
//  UserAction.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct AuthActions {
    struct LogIn: Action {
        var email: String!
        var password: String!
        init(password: String, email: String) {
            self.email = email
            self.password = password
        }
    }
    struct LogOut: Action {
        init() {}
        init(_ standardAction: StandardAction) {
        }
    }
    struct ChangePass: Action {
        var oldPass: String!
        var newPass: String!
        
        init(old: String, new: String) {
            oldPass = old
            newPass = new
        }
    }
}

struct UsersAction {
    struct get: Action {
        var uid: Int!
        var email: String!
        init(uid: Int) {
            self.uid = uid
        }
        init(email: String) {
            self.email = email
        }
        init() {
            
        }
    }
}


