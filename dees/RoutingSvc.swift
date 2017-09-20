//
//  RoutingSvc.swift
//  dees
//
//  Created by Leonardo Durazo on 19/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
enum StoryBoard: String {
    case main = "Main"
}

enum RoutingDestination: String {
    case weeksView = "WeeksTableViewController",
         enterprises = "EnterprisesTableViewController",
         allReports = "AllReportsTableViewController"
    case none = ""
}
extension RoutingDestination {
    func getStoryBoard() -> String {
        switch self {
        case .weeksView, .allReports,.enterprises, .none:
            return StoryBoard.main.rawValue
        }
    }
}
