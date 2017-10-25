//
//  FileService.swift
//  dees
//
//  Created by Leonardo Durazo on 12/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Moya
enum FileService {
    case get(wid: Int?, eid: Int)
}
extension FileService : TargetType, AccessTokenAuthorizable {
    var baseURL: URL { return URL(string: Constants.ServerApi.url)!}
    
    var path: String {
        switch self {
        case .get(let wid, let eid):
            if wid == nil {
                return "companies/\(eid)/res/library"
            }
            return "companies/\(eid)/res/library/week/\(wid!)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
         return ["Content-type": "application/json"]
    }
    
    var authorizationType: AuthorizationType {
        return .bearer
    }
}
