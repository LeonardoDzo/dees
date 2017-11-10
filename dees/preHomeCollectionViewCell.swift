//
//  preHomeCollectionViewCell.swift
//  dees
//
//  Created by Leonardo Durazo on 11/09/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

enum MENU_PRE {
    case ENTRAR,
         REPORTES,
         PENDIENTES,
         PDF
}

class preHomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var stackBtns: UIStackView!
    @IBOutlet weak var mainLogo: UIImageView!
    @IBOutlet weak var backgroundImg: UIImageView!
    
    @IBOutlet weak var pdfBtn: UIButton!
    weak var prehome: preHomeProtocol!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func handleClick(_ sender: UIButton) {
        prehome.section =  MENU_PRE.ENTRAR
        prehome.handleClick(sender: self.tag)
    }
   
    @IBAction func handleClickReports(_ sender: UIButton) {

        prehome.section = .REPORTES
        prehome.handleClick(sender: self.tag)
    }
    @IBAction func handleClickPendinngs(_ sender: Any) {

        prehome.section = .PENDIENTES
        prehome.handleClick(sender: self.tag)
    }
    @IBAction func handleClickPDF(_ sender: UIButton) {
        prehome.section = .PDF
        prehome.handleClick(sender: self.tag)
    }
}
