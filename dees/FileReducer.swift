//
//  FileReducer.swift
//  dees
//
//  Created by Leonardo Durazo on 12/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Moya
import Whisper
let fileProvider = MoyaProvider<FileService>(plugins: [authPlugin])

struct FileReducer  {
    func handleAction(action: Action, state: FileState?) -> FileState {

        var state = state ??  FileState(files: .loading)
        
        switch action {
        case let action as FileActions.get:
            if !token.isEmpty {
                state.files = .loading
                get(action.eid, action.wid)
            }
            break
        case let action as FileActions.delete:
            if action.report != nil {
                state.files = .loading
                self.delete(action.report, fid: action.fid)
            }
            break
        default:
            break
        }
        return state
    }
    
    
    func get(_ eid: Int,_ wid: Int? = nil) -> Void {
        
        fileProvider.request(.get(wid: wid, eid: eid), completion: {
            result in
            switch result {
            case .success(let response):
                do {
                    if let array : NSArray = try response.mapJSON() as? NSArray {
                        let file = File.from(array) ?? []
                        store.state.files.files = .Finished((file, messages.success._00))
                    }
                    print(response)
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
    func delete(_ report: Report, fid: Int) -> Void {
        
        fileProvider.request(.delete(report: report, fid: fid), completion: {
            result in
            switch result {
            case .success(let response):
        
                    if response.statusCode == 200 {
                        store.dispatch(ReportsAction.Get(eid: report.eid, wid: report.wid, uid: report.uid))
                    }else{
                        store.state.reportState.reports = .Failed(messages.error._06)
                    }
               
                break
            case .failure(let error):
                print(error)
                break
            }
        })
    }
}
