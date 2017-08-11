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
    case Normal, Superior
}

struct User : Mappable {
    static let kName = "name"
    static let kEmail = "email"
    static let kRol = "rol"
    static let kBusiness = "bussiness"
    
    var id: Int?
    var name: String?
    var email: String?
    var rol: Rol! = .Superior
    var bussiness = [Business]()
    
    init(json: NSDictionary) {
        self.id = json.value(forKey: "id") as? Int
        self.name = json.value(forKey: User.kName) as? String
        self.email = json.value(forKey:User.kEmail) as? String
        if  let val = json.value(forKey:User.kRol) as? Int {
            self.rol =  Rol(rawValue: val)
        }
    }
    init(map: Mapper) throws {
        try self.id = map.from("id")
        try self.email = map.from(User.kEmail)
        try self.name = map.from(User.kName)
       // try self.rol = Rol(rawValue: map.from(User.kRol))
    }
    init() {
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
