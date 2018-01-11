//
//  PreferencesViewController.swift
//  Formularios
//
//  Created by Adrián Rubio on 5/5/16.
//  Copyright © 2016 Adrián Rubio. All rights reserved.
//

import UIKit

class PreferencesViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var correoInventarios: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.correoInventarios.delegate = self
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let mail = userDefaults.objectForKey("correoInventarios") as? String
        {
            self.correoInventarios.text = mail
        }
        
        // Tap outside
        let tapOutside = UITapGestureRecognizer(target: self, action: #selector(InventoryTableViewController.handleTap(_:)))
        self.view.addGestureRecognizer(tapOutside)
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text
        {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            userDefaults.setObject(text, forKey: "correoInventarios")
        }
        return true
    }
    
    func handleTap(sender: AnyObject)
    {
        
        self.view.endEditing(false)
    }


}
