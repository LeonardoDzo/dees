//
//  preHomeCollectionViewCell.swift
//  dees
//
//  Created by Leonardo Durazo on 11/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class preHomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var stackBtns: UIStackView!
    
    @IBOutlet weak var mainLogo: UIImageView!
    @IBOutlet weak var backgroundImg: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let with = self.frame.width/3
        print(self.frame.width)
        
        
    }
    
    @IBAction func handleClick(_ sender: UIButton) {
        print("click inside \(self.tag)")
    }
   
    @IBAction func handleClickReports(_ sender: UIButton) {
        print("click on reports \(self.tag)")
    }
    @IBAction func handleClickPendinngs(_ sender: Any) {
        print("click on pendings \(self.tag)")
    }
}
