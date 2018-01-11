//
//  InventoryTableViewCell.swift
//  Formularios
//
//  Created by Adrián Rubio on 4/5/16.
//  Copyright © 2016 Adrián Rubio. All rights reserved.
//

import UIKit

class InventoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var elementsLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var stepper: UIStepper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
