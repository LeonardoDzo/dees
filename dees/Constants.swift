//
//  Constants.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Alamofire
struct Constants {
    struct ServerApi {
        static let url = "http://192.168.1.55:8083/api/"
        static let fileurl = "http://192.168.1.79:8083"
        static let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
    }
    
}
typealias api = Constants.ServerApi
