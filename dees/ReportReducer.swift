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

let reportsProvider = MoyaProvider<ReportService>(plugins: [authPlugin])
struct ReportReducer : Reducer {
    func handleAction(action: Action, state: ReportState?) -> ReportState {
        
        var state = state ?? ReportState(reports: [], weeks: [], status: .none)
        
        switch action {
        case let action as GetReportsByEnterpriseAndWeek:
            if action.eid != nil {
                state.status = .loading
                getWeeks()
            }
            break
        case is GetWeeksAction:
            if !token.isEmpty {
                state.status = .loading
                getWeeks()
            }
            break
        default:
            break
        }
        return state
    }
    
    func getReports(by wid: Int, eid: Int) -> Void {
        reportsProvider.request(.get(wid: wid, eid: eid), completion: {result in
            switch result {
            case .success(let response):
                do {
                    let repos : NSDictionary = try response.mapJSON() as! NSDictionary
                    let array : NSArray = repos.value(forKey: "reports") as! NSArray
                    
                    let reports = Report.from(array) ?? []
                    store.state.reportState.reports = reports
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
    func getWeeks() -> Void {
        reportsProvider.request(.getWeeks(), completion: {
            result in
            switch result {
            case .success(let response):
                do {
                    let repos : NSDictionary = try response.mapJSON() as! NSDictionary
                    let array : NSArray = repos.value(forKey: "weeks") as! NSArray
                    
                    let weeks = Week.from(array) ?? []
                    store.state.reportState.weeks = weeks
                    store.state.reportState.status = .none
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
