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
    var userState : UserState
    var businessState: BusinessState
    var reportState: ReportState
    var weekState : WeekState
    var files: FileState
    var pendingState: PendingsState
    var groupState : GroupState
}
enum Result<T> {
    case loading
    case failed
    case Failed(T)
    case finished
    case Finished(T)
    case none
}
