//
//  DesignableView.swift
//  dees
//
//  Created by Leonardo Durazo on 05/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

@IBDesignable class DesignableView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

}
