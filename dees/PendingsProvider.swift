//
//  PendingsProvider.swift
//  dees
//
//  Created by Leonardo Durazo on 17/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Alamofire
import Moya
import Mapper
enum PendingsService {
    case get(id: Int)
}
extension PendingsService: TargetType, AccessTokenAuthorizable {
    var path: String {
        switch self {
        case .get(let id):
            return "companies/\(id)/res/pendings"
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
    
    var baseURL: URL { return URL(string: Constants.ServerApi.url)! }
    
}

