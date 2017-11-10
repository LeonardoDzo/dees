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
    case main = "Main",
         files = "Files",
         chat = "Chat",
         enterprises = "Enterprises",
         pendings  = "Pendings",
         reports = "Reports"
}

enum RoutingDestination: String {
    case weeksView = "WeeksTableViewController",
         enterprises = "EnterprisesTableViewController",
         allReports = "AllReportsTableViewController",
         filesView = "FilesTableViewController",
         webView = "FileViewViewController",
         allPendings = "AllPendingsTableViewController",
         chatView = "ChatViewController",
         chatResponsables = "ResponsableTableViewController"
    case none = ""
}
extension RoutingDestination {
    func getStoryBoard() -> String {
        switch self {
        case .weeksView,.enterprises, .allPendings, .allReports,.none:
            return StoryBoard.main.rawValue
        case .chatView, .chatResponsables:
            return StoryBoard.chat.rawValue
        case .filesView, .webView:
            return StoryBoard.files.rawValue
        }
    }
}
