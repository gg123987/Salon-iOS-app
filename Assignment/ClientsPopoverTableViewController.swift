//
//  ClientsPopoverTableViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 11/5/2023.
//

import UIKit

/**
 protocol with a method to send selected client
 */
protocol ClientsPopoverDelegate: AnyObject {
    func didSelectClient(_ client: Client)
}

/**
 This class displays a list of clients fetched from Core Data. Users can select a client, and the selected client is passed to a delegate for further handling.
 */
class ClientsPopoverTableViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var clientList: [Client] = []
    
    weak var delegate: ClientsPopoverDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllClients()
        tableView.reloadData()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clientList.count
    }
    
    func getAllClients(){
        do {
            let initialList = try context.fetch(Client.fetchRequest())
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
            clientList = (initialList as NSArray).sortedArray(using: [sortDescriptor]) as! [Client]
        } catch {
            //error
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "clientListCell", for: indexPath)

        let client = clientList[indexPath.row]
        cell.textLabel?.text = client.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedClient = clientList[indexPath.row]
        
        delegate?.didSelectClient(selectedClient)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    

    

}
