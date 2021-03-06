//
//  MyMessageTableViewCell.swift
//  dees
//
//  Created by Leonardo Durazo on 26/10/17.
//  Copyright © 2017 Leonardo Durazo. All rights reserved.
//

import UIKit

class MyMessageTableViewCell: UITableViewCell, MessageBindible {

    var group: Group?
    var message: MessageEntitie!
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var textBubbleView: UIViewX!
    @IBOutlet weak var messageTxt: UITextView!
    @IBOutlet weak var weekLbl: UILabel!
    @IBOutlet weak var hourLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        if messageTxt != nil, message != nil {
            let size  = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: message.message).boundingRect(with: size, options: options, attributes:[NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
            self.messageTxt.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
            self.textBubbleView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 40)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
