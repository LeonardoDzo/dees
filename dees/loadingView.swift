//
//  loadingView.swift
//  dees
//
//  Created by Leonardo Durazo on 20/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit

class LoadingView: UIView {
    lazy var loading: UIImageView = {
       let img = UIImageView()
       img.frame.size.width = 100
       img.frame.size.height = 100
       img.formatView()
       img.loadGif(name: "firefly2")
       return img
    }()
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configureView() {
        backgroundColor = UIColor.clear
        alpha = 0.0
        addSubview(loading)
        
        widthAnchor.constraint(equalToConstant: CGFloat(100)).isActive = true
        heightAnchor.constraint(equalToConstant: CGFloat(100)).isActive = true
        loading.formatView()
    }
    
    override func draw(_ rect: CGRect) {
        frame = bounds
    }
    
    //MARK: - Animation
    
    fileprivate func hide() {
        UIView.animate(withDuration: 0.7) {[unowned self] in
            self.alpha = 0.0
        }
    }
    fileprivate func show() {
        UIView.animate(withDuration: 0.7) {[unowned self] in
            self.alpha = 1.0
        }
    }
   
}
extension LoadingView {
    //MARK: - Public API
    
    
    public func start() {
        show()
    }
    public func stop() {

        hide()
    }
    
}
