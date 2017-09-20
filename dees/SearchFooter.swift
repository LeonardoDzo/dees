//
//  SearchFooter.swift
//  dees
//
//  Created by Leonardo Durazo on 19/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit
class SearchFooter: UIView {
    
    let label: UILabel = UILabel()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configureView() {
        backgroundColor = #colorLiteral(red: 0.07843137255, green: 0.1019607843, blue: 0.1647058824, alpha: 1)
        alpha = 0.0
        
        // Configure label
        label.textAlignment = .center
        label.textColor = UIColor.white
        addSubview(label)
    }
    
    override func draw(_ rect: CGRect) {
        label.frame = bounds
    }
    
    //MARK: - Animation
    
    fileprivate func hideFooter() {
        UIView.animate(withDuration: 0.7) {[unowned self] in
            self.alpha = 0.0
        }
    }
    
    fileprivate func showFooter() {
        UIView.animate(withDuration: 0.7) {[unowned self] in
            self.alpha = 1.0
        }
    }
}
extension SearchFooter {
    //MARK: - Public API
    
    public func setNotFiltering() {
        label.text = ""
        hideFooter()
    }
    
    public func setIsFilteringToShow(filteredItemCount: Int, of totalItemCount: Int) {
        if (filteredItemCount == totalItemCount) {
            setNotFiltering()
        } else if (filteredItemCount == 0) {
            label.text = "No se encontraron resultados"
            showFooter()
        } else {
            label.text = "Filtrado \(filteredItemCount) de \(totalItemCount)"
            showFooter()
        }
    }
    
}
