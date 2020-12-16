//
//  JogDetailTableViewCell.swift
//  Joggers Log
//
//  Created by Nishant Thakur on 15/12/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import UIKit

class JogDetailTableViewCell: UITableViewCell {

    @IBOutlet var view: UIView!
    @IBOutlet var dateLBL: UILabel!
    @IBOutlet var timeLBL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = view.frame.height/5
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
