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
    case getByWeeks(wid: Int)
    case postReport(report: Report)
    case updateReport(report: Report)
    case getWeeks()

}
extension ReportService: TargetType, AccessTokenAuthorizable {
    var baseURL:URL {return URL(string: Constants.ServerApi.url)!}
    
    var path: String {
        switch self {
        case .get(let wid, let eid):
            return "Formats/Week/\(wid)/Enterprise/\(eid)"
        case .getByWeeks(let wid):
            return "Formats/Week/\(wid)/"
        case .getWeeks():
            return "res/weeks"
        case .postReport:
            return "Formats"
        case .updateReport(let report):
            return "Formats/\(report.id!)"
        }
    }
    var method: Moya.Method {
        switch self {
        case .get, .getWeeks, .getByWeeks:
            return .get
        case .postReport:
            return .post
        case .updateReport:
            return .put
        }
    }
    
    var shouldAuthorize: Bool {
        switch self {
        case .get,.getWeeks, .postReport, .updateReport, .getByWeeks:
            return true
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .get,.getWeeks, .getByWeeks:
            return nil
        case .postReport(let report):
            let r = report.toDictionary()
            return r  as? [String : Any]
        case .updateReport(let report):
            return report.toDictionary() as? [String : Any]
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .get, .getWeeks, .getByWeeks:
             return URLEncoding.default
        case .postReport,.updateReport:
             return JSONEncoding.default
        }
    }
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        switch self {
        case .get, .getWeeks, .postReport,.updateReport, .getByWeeks:
            return .request

        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    
}
