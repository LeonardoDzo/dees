//
//  BusinessState.swift
//  dees
//
//  Created by Leonardo Durazo on 08/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import ReSwift
struct BusinessState: StateType {
    var business = [Business]()
    var status: Result<Any>
    
    func getEnterprise(id: Int, enterprises: [Business]? = nil,handler: ((Business)->Void)) {
        let enterprises = enterprises ?? self.business
        enterprises.forEach({ (b)  in
            if b.id == id {
                handler(b)
            }else{
                if b.business.count > 0 {
                    self.getEnterprise(id: id, enterprises: b.business, handler: { b in 
                        handler(b)
                    })
                }
            }
        })
    }
}
