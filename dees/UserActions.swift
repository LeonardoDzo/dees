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
    struct Token: Action {
        var eid: Int!
        init(eid: Int) {
            self.eid = eid
        }
    }
    
    
}

struct UsersAction {
    struct get: Action {
        var eid: Int!
        var email: String!
        init(eid: Int) {
            self.eid = eid
        }
        
        init(email: String) {
            self.email = email
        }
        init() {
            
        }
    }
   
    
}
struct GroupsAction {
    struct SendMessage: Action {
        var message : _requestMessage!
        init(m: _requestMessage) {
            self.message = m
        }
    }
    struct GroupIn: Action {
        var message : _requestMessage!
        var gid : Int!
        var eid: Int!
        init(m: _requestMessage) {
            self.message = m
        }
        init(gid: Int, eid: Int) {
            self.eid = eid
            self.gid = gid
        }
    }
    struct Groups: Action {
        init() {
        }
    }
}

