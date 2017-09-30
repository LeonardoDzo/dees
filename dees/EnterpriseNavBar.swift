//
//  EnterpriseNavBar.swift
//  dees
//
//  Created by Leonardo Durazo on 29/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation

class EnterpriseNavBar {
    var items = [[Business]]()
    static let sharedInstance : EnterpriseNavBar = {
        let instance = EnterpriseNavBar()
        return instance
    }()

    private init(){
    }
    func push(_ item: [Business]) {
        items.append(item)
    }
    func pop() -> [Business] {
        return items.removeLast()
    }
    func removeAll() -> Void {
        items.removeAll()
    }
    
}
