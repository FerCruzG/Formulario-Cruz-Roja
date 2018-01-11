//
//  InventoryTableViewController.swift
//  Formularios
//
//  Created by Adrián Rubio on 4/5/16.
//  Copyright © 2016 Adrián Rubio. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import MessageUI


class InventoryTableViewController: UITableViewController,UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    let realm = try! Realm()
    
    
    var todos: Results<InventoryItem> {
        get {
            return realm.objects(InventoryItem)
        }
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        let tapOutside = UITapGestureRecognizer(target: self, action: #selector(InventoryTableViewController.handleTap(_:)))
        self.view.addGestureRecognizer(tapOutside)
    }
    
    @IBAction func sendEmailButtonTapped(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "No se pudo enviar el mensaje", message: "Tu dispositivo no tiene configurada una cuenta de correo aún.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let mail = userDefaults.objectForKey("correoInventarios") as? String
        {
            mailComposerVC.setToRecipients([mail])
        }
        
        mailComposerVC.setSubject("Inventario")

        
        var body = "Del la bodega se han tomado los siguientes artículos: \n"
        for t in todos
        {
            body += "\(t.count) de \(t.title)"+"\n"
        }
        mailComposerVC.setMessageBody(body, isHTML: false)
        
        return mailComposerVC
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        
        if result.rawValue == MFMailComposeResultSent.rawValue
        {
            try! realm.write {
                realm.deleteAll()
            }
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleTap(sender: AnyObject)
    {

        self.view.endEditing(false)
    }

    @IBAction func addItem(sender: UIBarButtonItem) {
        
        let item = InventoryItem()
        item.title = ""
        item.count = 1
        
        try! realm.write {
            realm.add(item)
        }
        
        self.tableView.reloadData()

    }
    
    @IBAction func stepperChanged(sender: UIStepper) {
        
        
        let val = sender.value
        let point = sender.convertPoint(CGPointZero, toView: self.tableView!)
        let indexPath = self.tableView.indexPathForRowAtPoint(point)!
        let current = todos[indexPath.row]

        try! realm.write {
            current.count = Int(val)
        }
        self.tableView.reloadData()
        
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        let point = textField.convertPoint(CGPointZero, toView: self.tableView!)
        let indexPath = self.tableView.indexPathForRowAtPoint(point)!
        let current = todos[indexPath.row]
        
        try! realm.write {
            if let t = textField.text
            {
                current.title = t

            }
        }
        self.tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todos.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("inventoryObject", forIndexPath: indexPath) as! InventoryTableViewCell
        
        let current = todos[indexPath.row]
        cell.titleTextField.text = current.title
        cell.elementsLabel.text = "\(current.count) " + (current.count == 1 ? "elemento" : "elementos")
        
        
        // Configure the cell...

        return cell
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let current = todos[indexPath.row]
            try! realm.write {
                realm.delete(current)
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } 
    }
 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
