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
}
extension MessageProvider : TargetType, AccessTokenAuthorizable {
    var baseURL:URL {return URL(string: Constants.ServerApi.url)!}
    
    var path: String {
        switch self {
        case .post(let m):
            let path =  "companies/\(m.eid!)/res/reply/\(m.type.rawValue)/user/\(m.uid!)"
            print(path)
            return path
        }
    }
    
    var method: Moya.Method {
        return .post
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
            
        }
    }
    var parameterEncoding: ParameterEncoding {
        
        return JSONEncoding.default
        
    }
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    
    var task: Task {
        return .requestParameters(parameters: self.parameters!, encoding: self.parameterEncoding)
    }
    
    var headers: [String: String]? {
        
        return ["Content-type": "application/json"]
        
    }
    
    
}

