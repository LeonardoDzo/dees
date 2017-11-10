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
enum ip : String {
    case ip_kike = "192.168.1.109"
    case ip_Test = "192.168.1.191"
    case ip_Prod = "biapi.cotecnologias.com"
    case ip_AWS = "ec2-54-183-230-51.us-west-1.compute.amazonaws.com"
}
extension ip  {
    func getPort() -> String {
        switch self {
        case .ip_kike:
            return ":8085/"
        case .ip_Test:
            return ":83/"
        case .ip_Prod, .ip_AWS:
            return "/"
        }
    }
}
struct Constants {
    struct ServerApi {
        static let uri = ip.ip_AWS
        static let url = "http://\(ServerApi.uri.rawValue)\(ServerApi.uri.getPort())api/"
        static let ws = "ws://\(ServerApi.uri.rawValue)\(ServerApi.uri.getPort())api/companies/"
        static let fileurl = "http://resapi.cotecnologias.com"
    }
    struct Announcement {
        
        /// Lista de posibles Errores
        struct error {
            /// Error Generico
            static let _00 = Murmur(title: "Ups!! Ocurrio un errors",  backgroundColor: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), titleColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
            /// Error al traer empresas
            static let _01 : Murmur! = {
                var error = messages.error._00
                error.title = "Error al traer Empresas"
                return error
            }()
            /// No se pudo eliminar la empresa
            static let _02 : Murmur! = {
                var error = messages.error._00
                error.title = "No se pudo eliminar la empresa"
                return error
            }()
            /// Email/Contraseña incorrecta
            static let _03 : Murmur! = {
                var error = messages.error._00
                error.title = "Email/Contraseña incorrecta"
                return error
            }()
            /// No tiene autorización
            static let _04 : Murmur! = {
                var error = messages.error._00
                error.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                error.title = "No tiene autorizacións"
                return error
            }()
            /// Por favor verifica tu internet
            static let _05 : Murmur! = {
                var error = messages.error._00
                error.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                error.title = "Por favor verifica tu internet"
                return error
            }()
            /// Algo malo paso en el servidor, por favor intentalo despues
            static let _06 : Murmur! = {
                var error = messages.error._00
                error.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                error.title = "Falló el servidor :("
                return error
            }()
        }
        /// Lista de mensajes de respuestas que salieron exitosas
        struct success {
            /// Success Generico
            static let _00 = Murmur(title: "Todo salió correctament!",  backgroundColor: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1), titleColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
            ///Se vio el reporte
            static let _01 : Murmur! = {
                var s = messages.success._00
                s.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
                s.title = "Se vio el reporte"
                return s
            }()
            ///Reporte actualizado
            static let _02 : Murmur! = {
                var s = messages.success._00
                s.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
                s.title = "Reporte actualizado"
                return s
            }()
            ///Información actualizada
            static let _03 : Murmur! = {
                var s = messages.success._00
                s.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
                s.title = "Información actualizada"
                return s
            }()
 
        }
    }
    
    struct Singletons {
        static let enterpriseNav = EnterpriseNavBar.sharedInstance
    }
    
}
typealias api = Constants.ServerApi
typealias messages = Constants.Announcement
typealias singleton = Constants.Singletons
