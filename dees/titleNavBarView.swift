//
//  titleNavBarView.swift
//  dees
//
//  Created by Leonardo Durazo on 22/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import Foundation
import UIKit

class titleNavBarView: UIView {
     var titleLabel : UILabel = {
        let titleLabel = UILabel(frame:  CGRect(x:0,y:-2,width: 0,height: 0))
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        return titleLabel
    }()
    var subtitleLabel : UILabel = {
        let subtitleLabel = UILabel(frame:  CGRect(x:0,y:18,width: 0,height: 0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = #colorLiteral(red: 0.5450980392, green: 0.8274509804, blue: 0.9764705882, alpha: 1)
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        return subtitleLabel
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        setTlb(title, subtitle)
    }
    func configureView() {
        frame = CGRect(x:0, y:0, width: max(self.titleLabel.frame.size.width,subtitleLabel.frame.size.width), height:30)
        backgroundColor = UIColor.clear
       
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
    }
    
    override func draw(_ rect: CGRect) {
        frame = bounds
    }
    
}
extension titleNavBarView {
     func setTlb(_ title: String, _ subtitle: String) -> Void {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        titleLabel.sizeToFit()
        subtitleLabel.sizeToFit()
        configureView()
    }
}
