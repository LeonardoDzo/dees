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
         create(e: Business),
         delete(id: Int),
         addUserAt(bid: Int, uid: Int),
         deleteUser(eid: Int, uid: Int),
         putEnterprise(enterprise: Business)
    
}
extension EnterpriseService: TargetType, AccessTokenAuthorizable {
    
    
    var baseURL: URL { return URL(string: "\(Constants.ServerApi.url)companies")! }
    var path: String {
        switch self {
        case .get(let id),.delete(let id):
            return"/\(id)/res/companies"
        case .getAll, .create:
            return ""
        case .addUserAt:
            return  "/AddUser"
        case .deleteUser(let eid, let uid):
            return "/\(eid)/\(uid)"
        case .putEnterprise(let enterprise):
            return "/\(enterprise.id!)"

        }
    }
    var method: Moya.Method {
        switch self {
        case .getAll, .get:
            return .get
        case .addUserAt,.create:
            return .post
        case .deleteUser,.delete:
            return .delete
        case .putEnterprise:
            return .put
        }
    }
    var authorizationType: AuthorizationType {
        return .bearer
    }
    var shouldAuthorize: Bool {
        switch self {
        case .getAll, .addUserAt, .deleteUser, .get, .putEnterprise, .create, .delete:
            return true
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .getAll, .deleteUser, .get, .delete:
            return nil
        case .addUserAt(let bid, let uid):
            return ["id_user": uid,
                    "id_enterprise": bid]
        case .putEnterprise(let e), .create(let e):
            return e.toDictionary() as? [String : Any]
        }
    }
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .getAll, .deleteUser, .get, .delete:
            return URLEncoding.default// Send parameters in URL for GET, DELETE and HEAD. For other HTTP methods, parameters will be sent in request body
        case .addUserAt, .putEnterprise, .create:
            return JSONEncoding.default
        }
    }
    var sampleData: Data {
        switch self {
        case .getAll, .addUserAt, .deleteUser, .get, .putEnterprise, .create, .delete:
            return "{ \"name\": \"Harry Potter\"}".utf8Encoded
        }
    }
    var task: Task {
        switch self {
        case .getAll,.deleteUser, .get, .delete:
            return .requestPlain
        case .addUserAt, .putEnterprise, .create:
            return .requestParameters(parameters: self.parameters!, encoding: self.parameterEncoding)
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

