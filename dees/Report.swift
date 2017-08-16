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
    static let kfinancial = "finance"
    static let kweekId = "id_week"
    static let kobservations = "observations"
    static let kenterpriseId = "id_enterprise"
    static let kuserId = "id_user"
    static let kreply = "reply"
    
    var id: Int!
    var operative:String?
    var financial: String?
    /// week Id
    var wid:Int!
    var observations:String?
    /// enterprise Id
    var eid:Int!
    /// User id
    var uid: Int!
    var reply: Bool? = false
    init(uid: Int, eid: Int, wid: Int) {
        operative = "No existe"
        financial = "No existe"
        observations = "No contiene Observaciones"
        self.eid = eid
        self.wid = wid
        self.uid = uid
    }
    
    init(map: Mapper) throws {
        try id = map.from(r.kid)
        operative = map.optionalFrom(r.koperative)
        financial = map.optionalFrom(r.kfinancial)
        try wid = map.from(r.kweekId)
        observations = map.optionalFrom(r.kobservations)
        try eid = map.from(r.kenterpriseId)
        try uid = map.from(r.kuserId)
        reply = map.optionalFrom(r.kreply)
    }
    func toDictionary() -> NSDictionary {
        return [
            r.kenterpriseId : self.eid,
            r.kfinancial : self.financial ?? "No existe financiero",
            r.kobservations : self.observations ?? "No existe observaciones",
            r.koperative : self.operative ?? "No existe operativo",
            r.kreply : self.reply ?? false,
            r.kuserId: self.uid,
            r.kweekId: self.wid
        ]
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
        guard let week = store.state.reportState.weeks.first(where: {$0.id == report.wid}) else {
            return
        }
        let date = Date().toMillis()
        let endDate = Date(string: week.endDate, formatter: .yearMonthAndDay)?.toMillis()
        if let operativeTxv = self.operativeTxv {
            operativeTxv.text = report.operative ?? ""
            if store.state.userState.user.id != report.uid || (endDate! < date!) {
                operativeTxv.isEditable = false
            }else{
                operativeTxv.isEditable = true
            }
        }
        if let observationsTxv = self.observationsTxv {
            observationsTxv.text = report.observations ?? ""
            if store.state.userState.user.rol == .Superior  {
                observationsTxv.isEditable = true
            }else{
                observationsTxv.isEditable = false
            }
        }
        if let financialTxv = self.financialTxv {
            financialTxv.text = report.financial ?? ""
            if store.state.userState.user.id != report.uid || (endDate! < date!) {
                financialTxv.isEditable = false
            }else{
                financialTxv.isEditable = true
            }
        }
        if let replySwt = self.replySwt {
            replySwt.isOn = report.reply ?? false
            if store.state.userState.user.rol == .Superior {
                replySwt.isEnabled = true
            }else{
                replySwt.isEnabled = false
            }
        }
        
    }
    
}
