//
//  BusquedaViewController.swift
//  Formularios
//
//  Created by Adrián Rubio on 4/28/16.
//  Copyright © 2016 Adrián Rubio. All rights reserved.
//

import UIKit
import CloudKit


class BusquedaViewController: UITableViewController, UISearchBarDelegate {
    
    
    enum Filter: String {
        case ParteDelServicio
        case NoAmbulancia
        case NoDeSampu
        case NombreDelOperador
        case Nombre
        case QueFueLoQuePaso
        case Observaciones
        case Colonia
        case Calle
        
        static let filtros = [ParteDelServicio,NoAmbulancia,NoDeSampu,NombreDelOperador,Nombre,QueFueLoQuePaso,Observaciones,Colonia,Calle]

    }
    
    var container : CKContainer!
    var publicDB : CKDatabase!
    var privateDB : CKDatabase!
    
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var dic = ["HoraDeRecep" : "Hora de recepción", "NoDeSampu":"Número de SAMPU", "KmInicial":"Kilometraje Inicial", "HoraDeLlegada":"Hora de llegada", "EntreLasCalles":"Entre calles", "UbicacionDelServicio":"Ubicación del servicio", "NoDeLesionados":"Número de lesionados", "Ocupacion":"Ocupación", "LesionesExternasQuePresenta":"Lesiones externas que presenta", "TrasladoAlHospital":"Traslado al hospital", "ParteDelServicio":"Parte del servicio", "Nombre":"Nombre", "KmFinal":"Kilometraje Final", "Observaciones":"Observaciones", "EstadoCivil":"Estado Civil", "TipoDeServicio":"Tipos de Servicio", "PuntoDeReferencia":"Punto de referencia", "Fecha":"Fecha", "LlamadaRecibidaDelTelefono":"Llamada recibida del telefono", "NoAmbulancia":"Número de Ambulancia", "JefeDeGuardia":"Jefe de guardia", "Sexo":"Sexo", "QueFueLoQuePaso":"Qué fue lo que pasó", "NombreDelOperador":"Nombre del operador", "Edad":"Edad", "QuienReporta":"Quien reporta", "Colonia":"Colonia", "Calle":"Calle", "PatrullasNo":"Número de patrulla", "HoraDeSalida":"Hora de salida"]
    
    var results = [CKRecord]()
    
    var filter = Filter.Nombre {
        didSet {
            self.searchBar.placeholder = "Buscar por \( keyToWords(self.filter.rawValue))"
            self.updateResults()
        }
    }
    
    var wordSearch = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //CloudKit
        self.container = CKContainer.defaultContainer()
        self.publicDB = container.publicCloudDatabase
        self.privateDB = container.privateCloudDatabase
        
        // Tap outside
//        let tapOutside = UITapGestureRecognizer(target: self, action: #selector(InventoryTableViewController.handleTap(_:)))
//        self.view.addGestureRecognizer(tapOutside)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
        
        
        self.updateResults()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.wordSearch = searchText
        self.updateResults()
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.updateResults()
        searchBar.resignFirstResponder()

    }
    
    @IBAction func selectFilter(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Filtro", message: "La información de la barra de búsqueda solo buscará en el campo elegido", preferredStyle: .ActionSheet)
        
        for f in Filter.filtros
        {
            let action = UIAlertAction(title: keyToWords(f.rawValue), style: .Default) { (action) in
                self.filter = f
                self.updateResults()
            }
            
            alert.addAction(action)
        }
        

        
        let cancel = UIAlertAction(title: "Cancelar", style: .Cancel) { (action) in
            //Nada
        }
        
        
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateResults()
    {
        HUD.show(HUDContentType.Progress)

        var predicate = NSPredicate(format: "TRUEPREDICATE")
        if self.wordSearch != "" {
            if [Filter.ParteDelServicio,Filter.NoAmbulancia,Filter.NoDeSampu].contains(self.filter)
            {
                if let num = Int(self.wordSearch)
                {
                    predicate = NSPredicate(format: "\(self.filter.rawValue) == %d", num)
                }

            }
            else
            {
                predicate = NSPredicate(format: "\(self.filter.rawValue) BEGINSWITH %@", self.wordSearch)
            }

        }
        

        
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        
        let query = CKQuery(recordType: "Formulario", predicate: predicate)
        query.sortDescriptors = [sort]
        self.publicDB.performQuery(query, inZoneWithID: nil) { (records, error) in
            
            if let r = records
            {
                self.results = r
                dispatch_async(dispatch_get_main_queue(),{
                    self.tableView.reloadData()
                    HUD.hide()

                })

            }
            
        }
        
    }
    
    
    func handleTap(sender: AnyObject)
    {
        
        self.view.endEditing(false)
    }
    
    func keyToWords(key: String) -> String
    {
        if let word = self.dic[key]
        {
            return word
        }
        return ""
    }

    func wordsToKey(words: String) -> String {
        
        for (key, value) in self.dic {
            if value == words
            {
                return key
            }
        }
        return ""
    }
    


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.results.count
    }

    @IBAction func refresh(sender: AnyObject) {
        self.updateResults()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath) as! ResultTableViewCell

        let current = self.results[indexPath.row]
        
        if let nombre = current[Filter.ParteDelServicio.rawValue]
        {
            cell.title.text = "Parte del servicio: \(nombre)"
        }else
        {
            cell.title.text = "<Nombre vacío>"
        }
        
        if let curr = current[self.filter.rawValue]
        {
            cell.subtitle.text = "\(self.keyToWords(self.filter.rawValue)): \(curr)"
        }else
        {
            cell.subtitle.text = "<Campo vacío>"
        }
        
    
        // Configure the cell...

        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let detail = segue.destinationViewController as! DetailsTableViewController
        let current = self.results[self.tableView.indexPathForSelectedRow!.row]

        if let curr = current[self.filter.rawValue]
        {
            detail.title = "\(self.keyToWords(self.filter.rawValue)): \(curr)"
        }
        else
        {
            detail.title = "<Campo vacío>"
        }
        
        var dictionary = [(title:String,subtitle:String)]()
        
        for k in current.allKeys() {
            dictionary.append( (self.keyToWords(k),"\(current.objectForKey(k)!)") )
        }
        
        detail.dictionary = dictionary
        

    }
    


}
