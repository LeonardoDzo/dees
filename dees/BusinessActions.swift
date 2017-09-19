//
//  BusinessReducer.swift
//  dees
//
//  Created by Leonardo Durazo on 08/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
typealias baction = BusinessAction
struct BusinessAction {
    struct Get: Action {
        var id : Int!
        init(id: Int = -1) {
            self.id = id
        }
    }
    struct Delete: Action {
        var id : Int!
        init(id: Int ) {
            self.id = id
        }
    }
    struct AddUser: Action {
        var uid:Int!
        var bid:Int!
        init(uid: Int, bid: Int) {
            self.uid = uid
            self.bid = bid
        }
    }
    struct Create: Action {
        var e:Business!
        init(e: Business) {
            self.e = e
        }
    }
    struct Put: Action {
        var enterprise : Business!
        init(e : Business) {
            self.enterprise = e
        }
    }
    
    struct DeleteUser: Action {
        var uid:Int!
        var bid:Int!
        init(uid: Int, bid: Int) {
            self.uid = uid
            self.bid = bid
        }
    }
}

