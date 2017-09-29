//
//  Constants.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Alamofire
import Whisper
struct Constants {
    struct ServerApi {
        static let url = "http://192.168.1.191:83/api/"
        static let fileurl = "http://resapi.cotecnologias.com"
        static let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
    }
    struct Announcement {
        static let notLogin = Message(title: "Email/Contraseña incorrecta", backgroundColor: .red)
        static let errorG = Message(title: "Ups!! Ocurrio un error", backgroundColor: .red)
        static let errorG_Murmur = Murmur(title: "Ups!! Ocurrio un error")
        static let loginFail_Murmur = Murmur(title: "Email/Contraseña incorrecta", backgroundColor: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
        static let succesG = Message(title: "Todo salió correctamente!", backgroundColor: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
        static let succes_01 = Murmur(title: "Actualizado!", backgroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), titleColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        static let error_01 = Message(title: "Error al traer las empresas!", backgroundColor: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))
        
    }
    
}
typealias api = Constants.ServerApi
typealias messages = Constants.Announcement
