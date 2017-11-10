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
    case delete(report: Report, fid: Int)
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
        case .delete(let report, let fid):
            return "companies/\(report.eid!)/res/reports/\(report.id!)/files/\(fid)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .get:
            return .get
        case .delete:
            return .delete
        }
    
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
