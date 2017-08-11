//
//  RerpotService.swift
//  dees
//
//  Created by Leonardo Durazo on 10/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Moya
enum ReportService {
    case get(wid: Int, eid: Int)
    case getWeeks()
}
extension ReportService: TargetType, AccessTokenAuthorizable {
    var baseURL:URL {return URL(string: Constants.ServerApi.url)!}
    
    var path: String {
        switch self {
        case .get(let wid,let eid):
            return "formats/week/\(wid)/enterprise/\(eid)"
        case .getWeeks():
            return "Weeks"
        }
    }
    var method: Moya.Method {
        switch self {
        case .get, .getWeeks:
            return .get
        
        
        }
    }
    
    var shouldAuthorize: Bool {
        switch self {
        case .get,.getWeeks:
            return true
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .get,.getWeeks:
            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .get, .getWeeks:
             return URLEncoding.default
        }
    }
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        switch self {
        case .get, .getWeeks:
            return .request

        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    
}
