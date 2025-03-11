//
//  ClientsTableTableViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 27/4/2023.
//

import UIKit
import UserNotifications

/**
 This function is responsible for displaying a list of clients in a table view. It fetches client
 data from CoreData and populates the table view cells with the client's name and phone number.
 The code also allows for deleting clients, navigating to view client details, and adding new clients.
 */
class ClientsTableTableViewController: UITableViewController {


    
    @IBOutlet var clientsTableView: UITableView!
    
    //context for CoreData operations
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var clientList: [Client] = []

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllClients()
        clientsTableView.reloadData()
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clientList.count
    }
    
    //function for creating the individual cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "clientCell", for: indexPath)
        let client = clientList[indexPath.row]
        cell.textLabel?.text = client.name
        cell.detailTextLabel?.text = client.phone
        return cell
        
    }
    
    //function to get all clients from CoreData
    func getAllClients(){
        do {
            let initialList = try context.fetch(Client.fetchRequest())
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
            clientList = (initialList as NSArray).sortedArray(using: [sortDescriptor]) as! [Client]
        } catch {
            //error
        }
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let this_client = clientList[indexPath.row]
            let alert = UIAlertController(title: "Are you sure?", message: "Deleting this client will remove all of their data.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                self.context.delete(this_client)
                do {
                    try self.context.save()
                    self.clientList.remove(at: indexPath.row)
                    self.clientsTableView.deleteRows(at: [indexPath], with: .fade)
                } catch{
                    //error
                }
            }))
            present(alert, animated: true)
        }
        
    }
    
    //function for cell selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedClient = clientList[indexPath.row]
        performSegue(withIdentifier: "viewClientSegue", sender: selectedClient)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
        
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addClientSegue" {
            let addClientVC = segue.destination as! AddNewClientViewController
            addClientVC.managedObjectContext = context
        }
        else if segue.identifier == "viewClientSegue" {
            let destinationVC = segue.destination as! ClientInfoViewController
            destinationVC.this_client = sender as? Client
            destinationVC.managedObjectContext = context
        }
    }

    
}
    
