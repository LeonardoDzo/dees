//
//  UIVIew.swift
//  dees
//
//  Created by Leonardo Durazo on 08/08/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit
extension UIView {
    func formatView() -> Void {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor( red: 204/255, green: 204/255, blue:204.0/255, alpha: 1.0 ).cgColor
    }
    func profileUser() -> Void {
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0

        self.layer.borderColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1).cgColor
    }
}
