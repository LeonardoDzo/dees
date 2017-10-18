//
//  AppReducer.swift
//  dees
//
//  Created by Leonardo Durazo on 04/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift


struct AppReducer {
    
    func handleAction(action: Action, state: AppState?) -> AppState {
        
        return AppState(
            userState: UserReducer().handleAction(action: action, state: state?.userState),
            businessState: BusinessReducer().handleAction(action: action, state: state?.businessState),
            reportState: ReportReducer().handleAction(action: action, state: state?.reportState),
            weekState: WeekReducer().handleAction(action: action, state: state?.weekState),
            files: FileReducer().handleAction(action: action, state: state?.files),
            pendingState: PendingReducer().handleAction(action: action, state: state?.pendingState)
        )
    }
    
}
