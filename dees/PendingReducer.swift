//
//  PendingReducer.swift
//  dees
//
//  Created by Leonardo Durazo on 17/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Moya
let pendingProvider = MoyaProvider<PendingsService>(plugins: [authPlugin])
struct PendingReducer  {
    func handleAction(action: Action, state: PendingsState?) -> PendingsState {
        
        var state = state ??  PendingsState(pendings: .loading)
        
        switch action {
        case let action as pActions.get:
            if !token.isEmpty {
                state.pendings = .loading
                getPendings(by : action.eid)
            }
            break
        default:
            break
        }
        return state
    }
    
    
    func getPendings(by eid: Int) -> Void {
        pendingProvider.request(.get(id: eid), completion: {
            result in
            switch result {
            case .success(let response):
                do {
                    if response.statusCode >= 400 && response.statusCode < 500  {
                        store.state.pendingState.pendings = .Failed(messages.error._04)
                        return
                    }else if response.statusCode >= 500 {
                        store.state.pendingState.pendings = .Failed(messages.error._06)
                        return
                    }
                    let array : NSDictionary = try response.mapJSON() as! NSDictionary
                    let pendings =  Pending.from( array["pendings"] as! NSArray) ?? []
                    let uncreate =  Pending.from( array["unexists"] as! NSArray) ?? []
                    store.state.pendingState.pendings = .Finished((pendings,uncreate))
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
