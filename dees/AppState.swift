//
//  AppState.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct AppState: StateType{
    var user : UserState
    var businessState: BusinessState
    var reportState: ReportState
}
enum Result<T> {
    case loading
    case failed
    case Failed(T)
    case finished
    case Finished(T)
    case noFamilies
    case none
}
