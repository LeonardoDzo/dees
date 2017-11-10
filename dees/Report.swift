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
import MIBadgeButton_Swift
struct seen : Mappable {
    static let kid = "id"
    static let kseenAt = "seenAt"
    static let kuserId = "userId"
    
    var id : Int!
    var seenAt: String!
    var userId: Int!
    
    init() {
        self.id = 0
        self.seenAt = ""
        self.userId = 0
    }
    
    init(map: Mapper) throws {
        try self.userId = map.from(seen.kuserId)
        try self.seenAt = map.from(seen.kseenAt)
        try self.id = map.from(seen.kid)
    }
}

struct Report : Mappable {
    typealias r = Report
    static let kid = "id"
    static let koperative = "operative"
    static let kfinancial = "financial"
    static let kweekId = "weekId"
    static let kobservations = "observation"
    static let kenterpriseId = "companyId"
    static let kuserId = "userId"
    static let kreply = "reply"
    static let kseens = "seen"
    static let kfiles = "files"
    
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
    var files = [File]()
    var seens = [seen]()
    
    init(uid: Int, eid: Int, wid: Int) {
        operative = ""
        financial = ""
        observations = ""
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
        seens = map.optionalFrom(r.kseens) ?? []
        files = map.optionalFrom(r.kfiles) ?? []
    }
    func toDictionary() -> NSDictionary {
        return [
            r.kenterpriseId : self.eid,
            r.kfinancial : self.financial ?? "No existe financiero",
            r.kobservations : self.observations ?? "No existe observaciones",
            r.koperative : self.operative ?? "No existe operativo",
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
    var anexosLbl: UILabel! {get}
    var replyF: MIBadgeButton! {get}
    var replyOp: MIBadgeButton! {get}
    var filesF: MIBadgeButton! {get}
    var filesOp: MIBadgeButton! {get}
    var observationTitle : UIStackView! {get}
}

extension ReportBindible {
    var operativeTxv: UITextView! {return nil}
    var observationsTxv: UITextView! {return nil}
    var financialTxv: UITextView! {return nil}
    var anexosLbl: UILabel! {return nil}
    var replyF: MIBadgeButton! {return nil}
    var replyOp: MIBadgeButton! {return nil}
    var filesF: MIBadgeButton! {return nil}
    var filesOp: MIBadgeButton! {return nil}
    var observationTitle : UIStackView! {return nil}
    
    func bind(by report: Report) -> Void {
        self.report = report
        bind()
    }
    
    func bind() -> Void {
        guard let report = report else {
            return
        }
        let groups = realm.realm.objects(Group.self).filter("companyId  = %@", report.eid)
        if let operativeTxv = self.operativeTxv {
            operativeTxv.text = report.operative ?? ""
            if store.state.userState.user.id != report.uid {
                //operativeTxv.isEditable = false
            }else{
                operativeTxv.isEditable = true
            }
        }
        if let observationsTxv = self.observationsTxv {
            observationsTxv.text = report.observations ?? ""
            if store.state.userState.user.permissions.contains(where: {$0.rid.rawValue > 601 }) {
                observationsTxv.isEditable = true
            }else{
                observationsTxv.isHidden = true
                observationsTxv.isEditable = false
            }
        }
        if let observationTitle = self.observationTitle {
            if !store.state.userState.user.permissions.contains(where: {$0.rid.rawValue > 601 }) {
                observationTitle.isHidden = true
            }
        }
        if let financialTxv = self.financialTxv {
            financialTxv.text = report.financial ?? ""
            if report.uid != store.state.userState.user.id {
                //financialTxv.isEditable = false
            }else{
                financialTxv.isEditable = true
            }
        }

        if let replyOp = self.replyOp {
            if !store.state.userState.user.isDirectorCeo(), groups.toArray(ofType: Group.self).filter({$0.type == 0}).count == 0  {
                replyOp.isHidden = true
            }
            
            
        }
        if let replyF = self.replyF {
            if !store.state.userState.user.isDirectorCeo(), groups.toArray(ofType: Group.self).filter({$0.type == 1}).count == 0  {
                replyF.isHidden = true
            }
        }
        
        if let filesOp = self.filesOp {
            filesOp.badgeString = "\(report.files.filter({$0.type == 0}).count)"
        }
        if let filesF = self.filesF {
             filesF.badgeString = "\(report.files.filter({$0.type == 1}).count)"
        }
        if let anexosLbl = anexosLbl {
            anexosLbl.text = report.files.count > 0 ? "Existen \(report.files.count)" : "No hay Reportes"
        }
        
    }
    
}
