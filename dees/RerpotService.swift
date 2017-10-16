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
    case get(wid: Int, eid: Int, uid: Int)
    case getByWeeks(wid: Int)
    case postReport(report: Report)
    case updateReport(report: Report)
    case getWeeks()
    case postFile(report: Report, type: Int, data: Data, name: String)
    
}
extension ReportService: TargetType, AccessTokenAuthorizable {
    var baseURL:URL {return URL(string: Constants.ServerApi.url)!}
    var path: String {
        switch self {
        case .get(let wid, let eid, let uid):
            return "companies/\(eid)/res/reports/search/\(uid)/\(wid)"
        case .getByWeeks(let wid):
            return "Formats/Week/\(wid)/"
        case .getWeeks():
            return "res/weeks"
        case .postReport:
            return "Formats"
        case .updateReport(let report):
            let path = "companies/\(report.eid!)/res/reports/\(report.id!)"
            return path
        case .postFile(let report, let type, _,_):
            let path = "companies/\(report.eid!)/res/reports/\(report.id!)/\(type)/files"
            return path
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
        case .postFile:
            return .post
        }
    }
    

    
    var shouldAuthorize: Bool {
        switch self {
        case .get,.getWeeks, .postReport, .updateReport, .getByWeeks, .postFile:
            return true
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .get,.getWeeks, .getByWeeks, .postFile:
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
        case .postFile:
            return URLEncoding.default
        }
    }
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    
    
    var task: Task {
        switch self {
        case .get, .getWeeks, .getByWeeks:
            return .request
        case .postReport,.updateReport:
            return .request
        case .postFile(_,_,let data, let name):
            let gifData = MultipartFormData(provider: .data(data), name: "file", fileName:"\(name)", mimeType: "")
            let multipartData = [gifData]
            return .upload(.multipart(multipartData))
           
        }
    }
    var headers: [String: String]? {
        switch self {
        case .postFile:
            return nil
        default:
            return ["Content-type": "application/json"]
        }
    }
    
}
