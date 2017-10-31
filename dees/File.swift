//
//  File.swift
//  dees
//
//  Created by Leonardo Durazo on 17/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import Mapper

enum FileType : String {
    case pdf = "application/pdf",
    jpg = "image/jpeg",
    png = "image/png",
    bpm = "image/bmp",
    pict = "image/pict",
    mac = "image/x-macpaint",
    tiff = "image/tiff",
    qti = "image/x-quicktime",
    gif = "image/gif",
    doc = "application/msword",
    docm = "pplication/vnd.ms-word.document.macroEnabled.12",
    docx = "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    xls = "application/vnd.ms-excel",
    ppt =  "application/vnd.ms-powerpoint",
    pptx = "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    pptm = "application/vnd.ms-powerpoint.presentation.macroEnabled.12",
    rar = "application/x-rar-compressed",
    zip = "application/x-zip-compressed",
    
    file = "other"
    
    
}
typealias ft = FileType

struct File: Mappable {
    static let kid = "id"
    static let kidFormat = "reportId"
    static let kname = "name"
    static let kpath = "uri"
    static let kextension = "extension"
    static let kmime = "mime"
    static let ktype = "type"
    static let kuserId = "userId"
    static let kweekId = "weekId"
    
    var id : Int!
    var fid: Int!
    var name: String?
    var ext: String?
    var mime: String?
    var type: Int?
    var path: String?
    var uid: Int?
    var wid: Int?
    init(map: Mapper) throws {
        try id = map.from(File.kid)
        try fid = map.from(File.kidFormat)
        name = map.optionalFrom(File.kname)
        ext = map.optionalFrom(File.kextension)
        mime = map.optionalFrom(File.kmime)
        type = map.optionalFrom(File.ktype)
        path = map.optionalFrom(File.kpath)
        uid = map.optionalFrom(File.kuserId)
        wid = map.optionalFrom(File.kweekId)
    }
    
    func getImage() -> UIImage {
        guard let file = FileType(rawValue: self.mime ?? "other") else {
            return #imageLiteral(resourceName: "File")
        }
        switch file {
        case ft.doc, ft.docm:
            return #imageLiteral(resourceName: "Doc-50")
        case ft.docx:
            return #imageLiteral(resourceName: "Microsoft Word-50")
        case ft.xls:
            return #imageLiteral(resourceName: "Microsoft Excel-50")
        case ft.ppt,ft.pptm, ft.pptx:
            return #imageLiteral(resourceName: "Microsoft PowerPoint-50")
        case ft.jpg:
            return #imageLiteral(resourceName: "JPG-50")
        case ft.png, .bpm, .pict, .mac, .tiff, .gif, .qti:
            return #imageLiteral(resourceName: "Image_50")
        case ft.pdf:
            return #imageLiteral(resourceName: "Pdf_50")
        case .rar:
            return #imageLiteral(resourceName: "WinRar")
        case .zip:
            return #imageLiteral(resourceName: "ZIP")
        case ft.file:
            return #imageLiteral(resourceName: "File")
        }
    }
    func isImage() -> Bool {
        guard let file = FileType(rawValue: self.mime ?? "other") else {
            return false
        }
        switch file {
            case ft.png, .bpm, .pict, .mac, .tiff, .gif, .qti, ft.jpg:
                return true
            default:
                return false
        }
        
    }
    
}
