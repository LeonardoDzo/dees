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
    case get(wid: Int, eid: Int)
}
extension FileService : TargetType, AccessTokenAuthorizable {
    var shouldAuthorize: Bool {
        return true
    }
    
    var parameters: [String : Any]? {
        return nil
    }
    
    var parameterEncoding: ParameterEncoding {
         return JSONEncoding.default
    }
    
    var baseURL: URL { return URL(string: Constants.ServerApi.url)!}
    
    var path: String {
        switch self {
        case .get(let wid, let eid):
            return "companies/\(eid)/res/library/week/\(wid)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        return .request
    }
    
    var headers: [String : String]? {
         return ["Content-type": "application/json"]
    }
    
}
