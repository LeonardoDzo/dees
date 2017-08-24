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

let businessActionTypeMap: TypeMap = [GetBusinessAction.type: GetBusinessAction.self, AddUserBusinessAction.type :  AddUserBusinessAction.self,
                                      CreateBusinessAction.type :  CreateBusinessAction.self,
                                       DeleteBusinessAction.type :  DeleteBusinessAction.self,
                                      DeleteUserBusinessAction.type : DeleteUserBusinessAction.self,PutBusinessAction.type: PutBusinessAction.self]

struct GetBusinessAction: StandardActionConvertible {
    static let type = "GET_BUSINESS_ACTION"
    var id : Int!
    init(id: Int = -1) {
        self.id = id
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: GetBusinessAction.type, payload: [:], isTypedAction: true)
    }
}
struct DeleteBusinessAction: StandardActionConvertible {
    static let type = "DELETE_BUSINESS_ACTION"
    var id : Int!
    init(id: Int ) {
        self.id = id
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: DeleteBusinessAction.type, payload: [:], isTypedAction: true)
    }
}
struct AddUserBusinessAction: StandardActionConvertible {
    static let type = "ADD_USER_BUSINESS_ACTION"
    var uid:Int!
    var bid:Int!
    init(uid: Int, bid: Int) {
        self.uid = uid
        self.bid = bid
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: AddUserBusinessAction.type, payload: [:], isTypedAction: true)
    }
}
struct CreateBusinessAction: StandardActionConvertible {
    static let type = "Create_BUSINESS_ACTION"
    var e:Business!
    init(e: Business) {
        self.e = e
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: CreateBusinessAction.type, payload: [:], isTypedAction: true)
    }
}
struct PutBusinessAction: StandardActionConvertible {
    static let type = "PUTBUSINESS_ACTION"
    var enterprise : Business!
    init(e : Business) {
        self.enterprise = e
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: PutBusinessAction.type, payload: [:], isTypedAction: true)
    }
}

struct DeleteUserBusinessAction: StandardActionConvertible {
    static let type = "DELETE_USER_BUSINESS_ACTION"
    var uid:Int!
    var bid:Int!
    init(uid: Int, bid: Int) {
        self.uid = uid
        self.bid = bid
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: DeleteUserBusinessAction.type, payload: [:], isTypedAction: true)
    }
}
