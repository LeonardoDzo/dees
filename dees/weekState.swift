//
//  weekState.swift
//  dees
//
//  Created by Leonardo Durazo on 10/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct WeekState: StateType {
   var weeks: Result<Any> = .loading
    
    func getWeeks() -> [Week] {
        switch self.weeks {
        case .Finished(let w as [Week]):
            return w
        default:
            return []
        }
    }
}
