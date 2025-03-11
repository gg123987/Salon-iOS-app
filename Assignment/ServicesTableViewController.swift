//
//  ServicesTableViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 27/4/2023.
//

import UIKit

/**
 This class is responsible for displaying a list of services in a table view. It fetches service data
 from CoreData and populates the table view cells with the service type and cost. The code also allows
 for deleting services, navigating to view service details, and adding new services.
 */
class ServicesTableViewController: UITableViewController {

    
    @IBOutlet var servicesTableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var appointmentTypeList: [AppointmentType] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllAppointmentTypes()
        servicesTableView.reloadData()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return appointmentTypeList.count
    }

    //creating the individual cells for the services
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell", for: indexPath) as! ServiceTableViewCell

        
        let this_appointmentType = appointmentTypeList[indexPath.row]
        cell.serviceTypeLabel.text = this_appointmentType.type
        cell.serviceCostLabel.text = this_appointmentType.cost
        return cell
    }
    
    //fetching all the appointment types from CoreData
    func getAllAppointmentTypes(){
        do {
            let initialList = try context.fetch(AppointmentType.fetchRequest())
            let sortDescriptor = NSSortDescriptor(key: "type", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
            appointmentTypeList = (initialList as NSArray).sortedArray(using: [sortDescriptor]) as! [AppointmentType]
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
            let this_appointmentType = appointmentTypeList[indexPath.row]
            let alert = UIAlertController(title: "Are you sure?", message: "Deleting this appointment type will remove all of its data.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                self.context.delete(this_appointmentType)
                do {
                    try self.context.save()
                    self.appointmentTypeList.remove(at: indexPath.row)
                    self.servicesTableView.deleteRows(at: [indexPath], with: .fade)
                } catch{
                    //error
                }
            }))
            present(alert, animated: true)
        }
        
    }
    
    //function for selecting a cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedService = appointmentTypeList[indexPath.row]
        performSegue(withIdentifier: "showServiceInfoSegue", sender: selectedService)
        if let indexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addServiceSegue" {
            let addServiceVC = segue.destination as! addNewServiceViewController
            addServiceVC.managedObjectContext = context
        }
        else if segue.identifier == "showServiceInfoSegue" {
            let destinationVC = segue.destination as! ServiceInfoViewController
            destinationVC.this_service = sender as? AppointmentType
            destinationVC.managedObjectContext = context
        }
    }
    

}
