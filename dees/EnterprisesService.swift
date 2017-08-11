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
    case getAll
}
extension EnterpriseService: TargetType, AccessTokenAuthorizable {
    var baseURL: URL { return URL(string: Constants.ServerApi.url)! }
    var path: String {
        switch self {
        case .getAll:
            return "Enterprises"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getAll:
            return .get
        }
    }
    var shouldAuthorize: Bool {
        switch self {
        case .getAll:
            return true
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .getAll:
            return nil
        }
    }
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .getAll:
            return URLEncoding.default// Send parameters in URL for GET, DELETE and HEAD. For other HTTP methods, parameters will be sent in request body
        }
    }
    var sampleData: Data {
        switch self {
        case .getAll:
            return "{ \"name\": \"Harry Potter\"}".utf8Encoded
        }
    }
    var task: Task {
        switch self {
        case .getAll:
            return .request
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

