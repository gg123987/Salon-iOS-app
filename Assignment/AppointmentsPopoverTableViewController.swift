//
//  AppointmentsPopoverTableViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 29/5/2023.
//

import UIKit

/**
 protocol with a method to send selected appointment type
 */
protocol AppointmentsPopoverDelegate: AnyObject {
    func didSelectAppointmentType(_ appointmentType: AppointmentType)
}

/**
 This class displays a list of appointment types fetched from Core Data. Users can select a type, and the selected type is passed to a delegate for further handling.
 */
class AppointmentsPopoverTableViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var appointmentTypeList: [AppointmentType] = []
    
    weak var delegate: AppointmentsPopoverDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllAppointmentTypes()
        tableView.reloadData()
        
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
    
    //getting all appointment types from CoreData
    func getAllAppointmentTypes(){
        do {
            let initialList = try context.fetch(AppointmentType.fetchRequest())
            let sortDescriptor = NSSortDescriptor(key: "type", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
            appointmentTypeList = (initialList as NSArray).sortedArray(using: [sortDescriptor]) as! [AppointmentType]
        } catch {
            //error
        }
    }

    //setting the cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentTypeCell", for: indexPath)

        let appointment = appointmentTypeList[indexPath.row]
        cell.textLabel?.text = appointment.type
        cell.detailTextLabel?.text = appointment.cost

        return cell
    }
    
    //handeling selecting the cells
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedAppointmentType = appointmentTypeList[indexPath.row]
        
        delegate?.didSelectAppointmentType(selectedAppointmentType)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        navigationController?.popViewController(animated: true)
        
    }


}
