//
//  UIString.swift
//  dees
//
//  Created by Leonardo Durazo on 11/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation


extension String
{
    func encodeUrl() -> String
    {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    func decodeUrl() -> String
    {
        return self.removingPercentEncoding!
    }
    
}
