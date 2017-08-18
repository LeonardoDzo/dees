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
enum EnterpriseService {
    case getAll,
         get(id: Int),
         addUserAt(bid: Int, uid: Int),
         deleteUser(eid: Int, uid: Int)
    
}
extension EnterpriseService: TargetType, AccessTokenAuthorizable {
    var baseURL: URL { return URL(string: "\(Constants.ServerApi.url)Enterprises")! }
    var path: String {
        switch self {
        case .get(let id):
            return"/\(id)"
        case .getAll:
            return ""
        case .addUserAt:
            return  "/AddUser"
        case .deleteUser(let eid, let uid):
            return "/\(eid)/\(uid)"

        }
    }
    var method: Moya.Method {
        switch self {
        case .getAll, .get:
            return .get
        case .addUserAt:
            return .post
        case .deleteUser:
            return .delete
        }
    }
    var shouldAuthorize: Bool {
        switch self {
        case .getAll, .addUserAt, .deleteUser, .get:
            return true
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .getAll, .deleteUser, .get:
            return nil
        case .addUserAt(let bid, let uid):
            return ["id_user": uid,
                    "id_enterprise": bid]
        }
    }
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .getAll, .deleteUser, .get:
            return URLEncoding.default// Send parameters in URL for GET, DELETE and HEAD. For other HTTP methods, parameters will be sent in request body
        case .addUserAt:
            return JSONEncoding.default
        }
    }
    var sampleData: Data {
        switch self {
        case .getAll, .addUserAt, .deleteUser, .get:
            return "{ \"name\": \"Harry Potter\"}".utf8Encoded
        }
    }
    var task: Task {
        switch self {
        case .getAll, .addUserAt, .deleteUser, .get:
            return .request
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

