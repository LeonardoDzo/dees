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
struct ReportReducer  {
    func handleAction(action: Action, state: ReportState?) -> ReportState {
        
        var state = state ?? ReportState(reports: .none)
        
        switch action {
        case let action as rAction.Get:
            state.reports = .loading
            getReports(by: action.wid, eid: action.eid, uid: action.uid)
            break
        case let action as rAction.Post:
            if action.report != nil {
                state.reports = .loading
                postUpdateReport(report: action.report)
            }
        case let action as rAction.UploadFile:
            if action.report != nil {
                state.reports = .loading
                uploadFile(report: action.report, file: action.data, type: action.type, name: action.name )
            }
            break
        default:
            break
        }
        return state
    }
    
    func getReports(by wid: Int?, eid: Int? = nil, uid: Int? = nil) -> Void {
        var request : ReportService!
        
        if eid != nil {
            request = ReportService.get(wid: wid!, eid: eid!, uid: uid!)
        }else if wid != nil {
            request = ReportService.getByWeeks(wid: wid!)
        }else {
            return
        }
        reportsProvider.request(request, completion: {result in
            switch result {
            case .success(let response):
                do {
                    let repos : NSDictionary = try response.mapJSON() as! NSDictionary
                    
                    let report = Report.from(repos)
                    store.state.reportState.reports = .Finished((report!, messages.success._03))
                    //                    if !store.state.reportState.reports.contains(where: {$0.id == report?.id}) {
                    //                            store.state.reportState.reports.append(report!)
                    //                    }else if let index = store.state.reportState.reports.index(where: {$0.id == report?.id}){
                    //                        store.state.reportState.reports[index] = report!
                    //                    }
                    
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
    
    func postUpdateReport(report: Report) -> Void {
        if report.id == nil {
            return
        }else {
            reportsProvider.request(.updateReport(report: report), completion: {
                result in
                switch result {
                case .success(let response):
                    do {
                        if response.statusCode == 404 || response.statusCode == 401 {
                            store.state.reportState.reports = .Failed(messages.error._04)
                            return
                        }
                        let repos : NSDictionary = try response.mapJSON() as! NSDictionary
                        
                        if let report = Report.from(repos) {
                            //                            if let index = store.state.reportState.reports.index(where: {$0.id == report.id}){
                            //                                store.state.reportState.reports[index] = report
                            //                                store.state.reportState.status = .Finished(messages.success._02)
                            //                            }
                            store.state.reportState.reports = .Finished((report, messages.success._03))
                        }
                        
                    } catch MoyaError.jsonMapping(let error) {
                        print(error )
                    } catch {
                        print(":(")
                    }
                    
                    break
                case .failure(let error):
                    store.state.reportState.reports = .Failed(messages.error._05)
                    print(error)
                    break
                }
            })
        }
    } 
    func uploadFile(report: Report, file: Data, type: Int, name: String) -> Void {
        if report.id == nil {
            return
        }else {
            reportsProvider.request(.postFile(report: report, type: type, data: file, name: name), completion: {
                result in
                switch result {
                case .success(let response):
                        if response.statusCode >= 400 && response.statusCode < 500  {
                            store.state.reportState.reports = .Failed(messages.error._04)
                            return
                        }else if response.statusCode >= 500 {
                            store.state.reportState.reports = .Failed(messages.error._06)
                            return
                        }
                        store.dispatch(ReportsAction.Get(eid: report.eid, wid: report.wid, uid: report.uid))
                    break
                case .failure(let error):
                    store.state.reportState.reports = .Failed(messages.error._05)
                    print(error)
                    break
                }
            })
        }
    }
}
