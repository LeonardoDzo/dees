//
//  ReportActions.swift
//  dees
//
//  Created by Leonardo Durazo on 10/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRecorder

let reportActionTypeMap: TypeMap = [GetReportsByEnterpriseAndWeek.type: GetReportsByEnterpriseAndWeek.self,
                                    GetWeeksAction.type: GetWeeksAction.self,
                                    SaveReportAction.type : SaveReportAction.self]

struct GetReportsByEnterpriseAndWeek : StandardActionConvertible {
    static let type = "ReportsEnterWeek_ACTION"
    var eid: Int!
    var wid: Int!
    init(eid: Int, wid: Int) {
        self.eid = eid
        self.wid = wid
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: GetReportsByEnterpriseAndWeek.type, payload: [:], isTypedAction: true)
    }

}

struct SaveReportAction: StandardActionConvertible {
    static let type = "SAVE_REPORT_ACTION"
    var report: Report!
    init(report: Report) {
        self.report = report
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: SaveReportAction.type, payload: [:], isTypedAction: true)
    }
    
}

struct GetWeeksAction : StandardActionConvertible {
    static let type = "GETWeeks_ACTION"
    init() {
    }
    init(_ standardAction: StandardAction) {
    }
    
    func toStandardAction() -> StandardAction {
        return StandardAction(type: GetWeeksAction.type, payload: [:], isTypedAction: true)
    }
    
}
