//
//  ExpandableHeaderView.swift
//  dees
//
//  Created by Leonardo Durazo on 18/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit
protocol ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpandableHeaderView, section: Int) -> Void
}

class ExpandableHeaderView: UITableViewHeaderFooterView {
    var delegate: ExpandableHeaderViewDelegate?
    var section: Int!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.selectHeaderAction(gestureReconizer:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectHeaderAction(gestureReconizer: UIGestureRecognizer) -> Void {
        let cell = gestureReconizer.view as! ExpandableHeaderView
        delegate?.toggleSection(header: self, section: cell.section)
    }
    func customInit(title: String, section: Int, delegate: ExpandableHeaderViewDelegate) -> Void {
        self.textLabel?.text = title
        self.section = section
        self.delegate = delegate
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.backgroundColor = #colorLiteral(red: 0.06009880453, green: 0.07446683198, blue: 0.1128933206, alpha: 1)
        self.textLabel?.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        self.textLabel?.font = UIFont(name: "pirulen", size: 13)
        
    }
    
}
