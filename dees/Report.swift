//
//  Report.swift
//  dees
//
//  Created by Leonardo Durazo on 10/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Mapper
import UIKit

struct Report : Mappable {
    typealias r = Report
    static let kid = "id"
    static let koperative = "operative"
    static let kfinancial = "financial"
    static let kweekId = "weekId"
    static let kobservations = "observations"
    static let kenterpriseId = "enterpriseId"
    static let kreply = "reply"
    
    var id: String!
    var operative:String?
    var financial: String?
    /// week Id
    var wid:Int?
    var observations:String?
    /// enterprise Id
    var eid:Int!
    var reply: Bool? = false
    init() {
        operative = ""
        financial = ""
        observations = ""
    }
    
    init(map: Mapper) throws {
        try id = map.from(r.kid)
        operative = map.optionalFrom(r.koperative)
        financial = map.optionalFrom(r.kfinancial)
        wid = map.optionalFrom(r.kweekId)
        observations = map.optionalFrom(r.kobservations)
        try eid = map.from(r.kenterpriseId)
        reply = map.optionalFrom(r.kreply)
    }
}

protocol ReportBindible: AnyObject {
    var report: Report! {get set}
    var operativeTxv: UITextView! {get}
    var observationsTxv: UITextView! {get}
    var financialTxv: UITextView! {get}
    var replySwt: UISwitch! {get}
}

extension ReportBindible {
    var operativeTxv: UITextView! {return nil}
    var observationsTxv: UITextView! {return nil}
    var financialTxv: UITextView! {return nil}
    var replySwt: UISwitch! {return nil}
    
    func bind(by report: Report) -> Void {
        self.report = report
        bind()
    }
    
    func bind() -> Void {
        guard let report = report else {
            return
        }
        
        if let operativeTxv = self.operativeTxv {
            operativeTxv.text = report.operative ?? ""
        }
        if let operativeTxv = self.operativeTxv {
            operativeTxv.text = report.operative ?? ""
        }
        if let financialTxv = self.financialTxv {
            financialTxv.text = report.financial ?? ""
        }
        if let replySwt = self.replySwt {
            replySwt.isOn = report.reply ?? false
        }
        
    }
    
}
