//
//  businessRecorder.swift
//  dees
//
//  Created by Leonardo Durazo on 08/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Alamofire
import Moya
import Mapper
let businessProvider = MoyaProvider<EnterpriseService>(plugins: [authPlugin])

struct BusinessReducer: Reducer {
    func handleAction(action: Action, state: BusinessState?) -> BusinessState {
        var state = state ?? BusinessState(business: [], status: .none)
        switch action {
        case is GetBusinessAction:
            if token != "" {
                state.status = .loading
                getEnterprise()

            }
        break
        case is GetWeeksAction:
            if !token.isEmpty {
                state.status = .loading
            }
            break
        default:
            break
        }
        return state
    }
    
    func getEnterprise() -> Void {
        businessProvider.request(.getAll, completion: {
            result in
            switch result {
            case .success(let response):
                do {
                    let repos : NSDictionary = try response.mapJSON() as! NSDictionary
                    let array : NSArray = repos.value(forKey: "enterprises") as! NSArray
                    
                    let enterprises = Business.from(array) ?? []
                    store.state.businessState.business = enterprises
                } catch MoyaError.jsonMapping(let error) {
                    print(error )
                } catch {
                    print(":(")
                }

                break
            case .failure(let error):
                print(error)
                break
            }
        })
    }
    
    
}
