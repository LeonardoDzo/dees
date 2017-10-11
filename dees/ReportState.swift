//
//  ReportState.swift
//  dees
//
//  Created by Leonardo Durazo on 10/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift

struct ReportState: StateType {
    var reports: Result<Any> = .loading
}
