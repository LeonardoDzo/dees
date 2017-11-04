//
//  MessageService.swift
//  dees
//
//  Created by Leonardo Durazo on 24/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Moya

enum TYPE_ON_REPORT : Int {
    case OPERATIVE,
    FINANCIAL
}

protocol _request {
    var eid : Int! { get set }
    
}

struct _requestMessage : _request {
    var eid: Int!
    var wid: Int!
    var uid: Int!
    var type: TYPE_ON_REPORT!
    var message: String!
}


enum MessageProvider {
    case post(m : _requestMessage)
    case get(m: _requestMessage)
    case getBy(eid: Int,gid: Int )
    case groups()
}
extension MessageProvider : TargetType, AccessTokenAuthorizable {
    var baseURL:URL {return URL(string: Constants.ServerApi.url)!}
    
    var path: String {
        switch self {
        case .post(let m), .get(let m) :
            let path =  "companies/\(m.eid!)/res/reply/\(m.type.rawValue)/user/\(m.uid!)"
            return path
        case .getBy(let eid, let gid):
            return "companies/\(eid)/res/groups/\(gid)"
        case .groups:
            return "companies/0/res/groups"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .get, .groups, .getBy:
            return .get
        case .post:
            return .post
        }
    }
    var authorizationType: AuthorizationType {
        return .bearer
    }
    var shouldAuthorize: Bool {
        return true
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .post(let m):
            return ["message": m.message,
                    "tags": "",
                    "weekId": m.wid]
        case .get, .groups, .getBy:
            return nil
        }
    }
    var parameterEncoding: ParameterEncoding {
        
        return JSONEncoding.default
        
    }
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    
    var task: Task {
        switch self {
        case .post:
            return .requestParameters(parameters: self.parameters!, encoding: self.parameterEncoding)
        case .get, .groups(), .getBy:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        
        return ["Content-type": "application/json"]
        
    }
    
    
}

