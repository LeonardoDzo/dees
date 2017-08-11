//
//  RequestService.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Alamofire
import Moya
import Mapper
enum AuthService {
    case login(email: String, passwd: String)
}
extension AuthService: TargetType, AccessTokenAuthorizable {
    var baseURL: URL { return URL(string: Constants.ServerApi.url)! }
    var path: String {
        switch self {
        case .login(_,_):
            return "auth/login"
        }
    }
    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        }
    }
    var shouldAuthorize: Bool {
        switch self {
        case .login:
            return false
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .login(let email, let passwd):
            return [User.kEmail: email,
                    "password": passwd]
        }
    }
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .login:
            return JSONEncoding.default// Send parameters in URL for GET, DELETE and HEAD. For other HTTP methods, parameters will be sent in request body
        }
    }
    var sampleData: Data {
        switch self {
        case .login(_,_):
            return "{\"name\": \"Harry Potter\"}".utf8Encoded
        }
    }
    var task: Task {
        switch self {
        case .login:
            return .request
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    
   
    

}
