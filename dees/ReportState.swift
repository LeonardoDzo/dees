//
//  ReportState.swift
//  dees
//
//  Created by Leonardo Durazo on 10/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import Whisper
struct ReportState: StateType {
    var reports: Result<Any> = .none
}
struct FileState: StateType {
    var files: Result<Any> = .none
    
    func get() -> [File] {
        switch self.files {
        case .Finished(let w as ([File], Murmur)):
            return w.0
        default:
            return []
        }
    }
}

