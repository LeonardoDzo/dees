//
//  WeekReducer.swift
//  dees
//
//  Created by Leonardo Durazo on 10/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
//
//  ReportReducer.swift
//  dees
//
//  Created by Leonardo Durazo on 10/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Moya

struct WeekReducer  {
    func handleAction(action: Action, state: WeekState?) -> WeekState {
        
        var state = state ??  WeekState(weeks: .loading)
        
        switch action {
        case is wAction.Get:
            if !token.isEmpty {
                state.weeks = .loading
                getWeeks()
            }
            break
        default:
            break
        }
        return state
    }
    
   
    func getWeeks() -> Void {
        reportsProvider.request(.getWeeks(), completion: {
            result in
            switch result {
            case .success(let response):
                do {
                    let array : NSArray = try response.mapJSON() as! NSArray
                    let weeks = Week.from(array) ?? []
                    store.state.weekState.weeks = .Finished(weeks)
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
