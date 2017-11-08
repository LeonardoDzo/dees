//
//  AnimationController.swift
//  dees
//
//  Created by Leonardo Durazo on 07/11/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit
class AnimationController {
    var ctrl : UIViewController!
    var controls = [UIView]()
    var backgroundview: UIView!
    init(target: UIViewController, controls: [UIView]) {
        self.ctrl = target
        self.controls = controls
        
        backgroundview = UIView(frame: ctrl.view.frame)
        backgroundview.backgroundColor = #colorLiteral(red: 0.3575025797, green: 0.3553826213, blue: 0.3591355383, alpha: 0.7041416952)
        ctrl.view.addSubview(backgroundview)
        animation()
    }
    
    func animation() -> Void {
        controls.forEach { (view) in
            if let c = view as? UICollectionView {
                if let cell = c.cellForItem(at: IndexPath(item: 0, section: 0)){
                    ctrl.view.addSubview(cell)
                }
            }
        }
    }

}
