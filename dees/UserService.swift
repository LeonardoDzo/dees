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
enum UserService {
    case showUser(id: Int)
    case updateUser(id:Int, name: String)
    case changePass(old: String, new: String)
}
extension UserService: TargetType, AccessTokenAuthorizable {
    var baseURL: URL { return URL(string: Constants.ServerApi.url)! }
    var path: String {
        switch self {
        case .showUser(let id), .updateUser(let id, _):
            return "users/\(id)"
        case .changePass:
            return "Users/Reset_Password"
        }
        
    }
    var method: Moya.Method {
        switch self {
        case .showUser:
            return .get
        case .updateUser, .changePass:
            return .post
        }
    }
    var shouldAuthorize: Bool {
        switch self {
        case .showUser, .updateUser, .changePass:
            return true
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .showUser:
            return nil
        case .updateUser(_, let name):
            return [User.kName: name]
        case .changePass(let old,let new):
            return  ["old_password": old,
                     "new_password": new]
        }
    }
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .showUser:
            return URLEncoding.default// Send parameters in URL for GET, DELETE and HEAD. For other HTTP methods, parameters will be sent in request body
        case .updateUser, .changePass:
            return JSONEncoding.default// Always sends parameters in URL, regardless of which HTTP method is used
        }
    }
    var sampleData: Data {
        switch self {
        case .showUser(let id):
            return "{\"id\": \(id), \"name\": \"Harry Potter\"}".utf8Encoded
        case .updateUser(let id, let name):
            return "{\"id\": \(id), \"name\": \"\(name)\"}".utf8Encoded
        case .changePass:
            return "asdasd".utf8Encoded
        }
    }
    var task: Task {
        switch self {
        case .showUser, .updateUser, .changePass:
            return .request
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
// MARK: - Helpers
extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return self.data(using: .utf8)!
    }
}
