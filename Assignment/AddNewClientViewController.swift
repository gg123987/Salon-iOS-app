//
//  AddNewClientViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 10/5/2023.
//

import UIKit
import CoreData

/**
 This class manages the process of adding new clients to the app. It allows users to enter client details, such as name, phone number, and email address.
 The class saves the client information to Core Data, and it includes a method to check for duplicate client entries.
 */
class AddNewClientViewController: UIViewController {
    
    var clientToEdit: Client?
    
    var managedObjectContext: NSManagedObjectContext!

    @IBOutlet weak var clientName: UITextField!
    
    @IBOutlet weak var clientPhone: UITextField!
    
    @IBOutlet weak var clientEmail: UITextField!
    
    //function to save the client to CoreData
    @IBAction func saveClient(_ sender: Any) {
        
        guard let name = clientName.text, !name.isEmpty, let email = clientEmail.text, let phone = clientPhone.text,!phone.isEmpty
        else {
                displayMessage(title: "Error", message: "Please ensure all fields are filled")
                return
            }

        if let client = clientToEdit{
            client.name = name
            client.email = email
            client.phone = phone
        }
        else{
            
            if doesClientExist(name: name){
                displayMessage(title: "Error", message: "Client already exists")
                return
            }
            
            let this_client = Client(context: managedObjectContext)
            this_client.name = name
            this_client.email = email
            this_client.phone = phone
        }
        do{
            try managedObjectContext.save()
            navigationController?.popViewController(animated: true)
        }
        catch{
            //error
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if clientToEdit != nil{
            clientName.text = clientToEdit?.name
            clientPhone.text = clientToEdit?.phone
            if clientToEdit?.email == ""{
                clientEmail.text = ""
            }
            else{
                clientEmail.text = clientToEdit?.email
            }
        }
        clientName.addDoneButton()
        clientEmail.addDoneButton()
        clientPhone.addDoneButton()

        // Do any additional setup after loading the view.
    }
    
    //function to check if a client exists in CoreData with the given name
    func doesClientExist(name: String) -> Bool{
        var allClients: [Client] = []
        var doesExist = false
        do {
            let initialList = try managedObjectContext.fetch(Client.fetchRequest())
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
            allClients = (initialList as NSArray).sortedArray(using: [sortDescriptor]) as! [Client]
        } catch {
            //error
        }
        for client in allClients{
            if client.name == name{
                doesExist = true
                break
            }
        }
        return doesExist
    }


}
