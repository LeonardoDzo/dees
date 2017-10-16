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
        default:
            break
        }
        return state
    }
    
    
    func get(_ eid: Int,_ wid: Int) -> Void {
        fileProvider.request(.get(wid: wid, eid: eid), completion: {
            result in
            switch result {
            case .success(let response):
                do {
                    let array : NSArray = try response.mapJSON() as! NSArray
                    let file = File.from(array) ?? []
                    store.state.files.files = .Finished((file, messages.success._00))
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
