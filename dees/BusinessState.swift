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
    
    func getEnterprise(id: Int) -> Business? {
        var enterprise : Business!
        _  = self.business.map({ (b) -> Business in
            if b.id == id {
                enterprise = b
            }else{
                _ = b.business.map({ (b1) -> Business in
                    if b1.id == id  {
                        enterprise = b1
                    }
                    return b1
                })
                
                return b
            }
            return b
        })
        return enterprise
    }
}
