//
//  User.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit
import Mapper
enum Rol: Int {
    case Operative = 601,
         Director,
         CEO
}

struct User : Mappable {
    static let kName = "name"
    static let kEmail = "email"
    static let kRol = "role"
    static let kBusiness = "companies"
    static let kPermission = "permissions"
    
    var id: Int?
    var name: String?
    var email: String?
    var bussiness = [Business]()
    
    var permissions = [Permission]()
    init(map: Mapper) throws {
        if let userDic : NSDictionary = map.optionalFrom("user") {
           try self.userInfo(map: Mapper(JSON: userDic))
        }
        self.permissions = map.optionalFrom(User.kPermission) ?? []
        self.bussiness = map.optionalFrom(User.kBusiness) ?? []
        
    }
    mutating func userInfo(map: Mapper) throws -> Void {
        try self.id = map.from("id")
        try self.email = map.from(User.kEmail)
        try self.name = map.from(User.kName)
    }
    init() {
    }
    func toDictionary() -> NSDictionary {
        return [User.kEmail: self.email ?? "",
                User.kName: self.name ?? ""]
        
    }
    
}
protocol UserBindible: AnyObject {
    var user: User! {get set}
    var nameLbl: UILabel! {get}
    var emailLbl: UILabel! {get}
}
extension UserBindible {
    var nameLbl: UILabel! {return nil}
    var emailLbl: UILabel! {return nil}
    
    func bind(user: User) -> Void {
        self.user = user
        bind()
    }
    func bind() -> Void {
        guard let user = self.user else {
            return
        }
        if let nameLbl = self.nameLbl {
            nameLbl.text = user.name
        }
        if let emailLbl = self.emailLbl {
            emailLbl.text = user.email
        }
    }
}
