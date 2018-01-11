//
//  FormTableViewController.swift
//  Formularios
//
//  Created by Adrián Rubio on 4/5/16.
//  Copyright © 2016 Adrián Rubio. All rights reserved.
//

import UIKit
import CloudKit

extension UIDatePicker
{
    func dateString() -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .NoStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "es_MX")
        return dateFormatter.stringFromDate(self.date)
    }
    
    func timeString() -> String
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "es_MX")
        return dateFormatter.stringFromDate(self.date)
    }
}

class FormTextField: UITextField
{
    @IBInspectable var cloudDataAttributeString:String? = ""
    
    var storedDate: NSDate?
}

class FormTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate {
    
    var container : CKContainer!
    var publicDB : CKDatabase!
    var privateDB : CKDatabase!
    
    @IBOutlet var datePicker: UIDatePicker!

    @IBOutlet var textFields:[UITextField] = []
    
    @IBOutlet var textFieldsToValidate:[UITextField] = []

    
    var currentTextField: UITextField?
    
    @IBOutlet weak var queFueLoQuePasoTextView: UITextView!
    
    @IBOutlet weak var observacionesTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //CloudKit
        self.container = CKContainer.defaultContainer()
        self.publicDB = container.publicCloudDatabase
        self.privateDB = container.privateCloudDatabase
        
     
        
        //Text delegate
        for tf in self.textFields
        {
            tf.clearButtonMode = .Always
            tf.delegate = self
            
//            switch tf.tag {
//            case 1,2:
//                tf.inputAssistantItem.leadingBarButtonGroups = []
//                tf.inputAssistantItem.trailingBarButtonGroups = []
//            default:
//                break
//            }
        }
        
        
        // Tap outside
        let tapOutside = UITapGestureRecognizer(target: self, action: #selector(InventoryTableViewController.handleTap(_:)))
        self.view.addGestureRecognizer(tapOutside)
        
    }
    @IBOutlet weak var hombreMujerSegmentedControl: UISegmentedControl!
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        self.currentTextField = textField
        
        switch textField.tag {
        case 1:
            let dateTextField = textField as! FormTextField
            self.datePicker.datePickerMode = .Date
            dateTextField.inputView = self.datePicker
            dateTextField.storedDate = self.datePicker.date
            dateTextField.text = self.datePicker.dateString()
        case 2:
            let dateTextField = textField as! FormTextField
            self.datePicker.datePickerMode = .Time
            textField.inputView = self.datePicker
            dateTextField.storedDate = self.datePicker.date
            textField.text = self.datePicker.timeString()
        default:
            break
        }

        
    }
    
    @IBAction func datePickerChanged(sender: UIDatePicker) {
        if let c = self.currentTextField
        {
            switch c.tag {
            case 1:
                let dateTextField = c as! FormTextField
                dateTextField.storedDate = self.datePicker.date
                c.text = self.datePicker.dateString()
            case 2:
                let dateTextField = c as! FormTextField
                dateTextField.storedDate = self.datePicker.date
                c.text = self.datePicker.timeString()
            default:
                break
            }
        }
    }
    
    
    func handleTap(sender: AnyObject)
    {
        
        self.view.endEditing(false)
    }
    
    func validateFields() -> Bool
    {
        
        var textFieldTexts = [String]()
        
        for f in self.textFieldsToValidate
        {
            if let text = f.text where text.isEmpty
            {
                textFieldTexts.append(f.placeholder!)
            }
        }
        
        
        let message = textFieldTexts.joinWithSeparator("\n")
        let alert = UIAlertController(title: "Los siguientes campos no pueden estar vacíos:", message: message, preferredStyle: .Alert)
        
        let cancel = UIAlertAction(title: "Aceptar", style: .Default) { (action) in
            //Nada por ahora
        }
        
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: nil)
        
        

        return textFieldTexts.isEmpty
    }
    
    
    
    @IBAction func guardarFormulario(sender: AnyObject) {
        
        if validateFields()
        {
            let alert = UIAlertController(title: "Confirmación", message: "¿Está seguro que desea guardar los datos de este formulario?", preferredStyle: .ActionSheet)
            
            let action = UIAlertAction(title: "Guardar", style: .Default) { (action) in
                self.guardarDatos()
            }
            
            alert.addAction(action)
            
            let cancel = UIAlertAction(title: "Cancelar", style: .Cancel) { (action) in
                //Nada
            }
            
            
            alert.addAction(cancel)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }

        
    }
    
    func guardarDatos()
    {
        let record = CKRecord(recordType: "Formulario")
        for t in self.textFields
        {
            let formTextField = t as! FormTextField
            if let key = formTextField.cloudDataAttributeString where formTextField.text != nil
            {
                switch formTextField.tag {
                case 1,2:
                    record.setValue(formTextField.storedDate, forKey: key)
                case 3:
                    record.setValue(Int(formTextField.text!), forKey: key)
                default:
                    record.setValue(formTextField.text!, forKey: key)
                }
                
            }

        }
        
        record.setValue(self.hombreMujerSegmentedControl.selectedSegmentIndex, forKey: "Sexo")
        record.setValue(self.queFueLoQuePasoTextView.text, forKey: "QueFueLoQuePaso")
        record.setValue(self.observacionesTextView.text, forKey: "Observaciones")

        
        publicDB.saveRecord(record) { savedRecord, error in
            if let err = error
            {
                print(err)
                
                dispatch_async(dispatch_get_main_queue(),{
                    let alert = UIAlertController(title: "Error", message: "Ocurrió un error al enviar los datos, verifique que tiene conexión a internet y que esté logeado en su cuenta de iCloud.", preferredStyle: .Alert)
                    
                    let cancel = UIAlertAction(title: "Aceptar", style: .Default) { (action) in
                        //Nada por ahora
                    }
                    
                    alert.addAction(cancel)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                })
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),{
                    let alert = UIAlertController(title: "Listo!", message: "Su formulario se ha guardado exitosamente.", preferredStyle: .Alert)
                    
                    let cancel = UIAlertAction(title: "Aceptar", style: .Default) { (action) in
                        self.limpiarCampos()
                    }
                    
                    alert.addAction(cancel)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                })
            }
        }
        


        
    }
    
    
    func limpiarCampos()
    {
        for t in self.textFields
        {
            let dateTextField = t as! FormTextField
            dateTextField.storedDate = nil
            t.text = ""
        }
        
        self.hombreMujerSegmentedControl.selectedSegmentIndex = 0
        self.queFueLoQuePasoTextView.text = ""
        self.observacionesTextView.text = ""
    }

    @IBAction func cleanFields(sender: AnyObject) {
        
        let alert = UIAlertController(title: "¿Seguro?", message: "¿Está seguro que desea limpiar todos los campos del formulario actual?", preferredStyle: .ActionSheet)
        
        let action = UIAlertAction(title: "Limpiar", style: .Destructive) { (action) in
            self.limpiarCampos()
        }
        
        alert.addAction(action)
        
        let cancel = UIAlertAction(title: "Cancelar", style: .Cancel) { (action) in
        }
        
        
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
     
    }


}
