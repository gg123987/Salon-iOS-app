//
//  addNewServiceViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 18/5/2023.
//

import UIKit
import CoreData

/**
 This class is responsible for adding or editing an appointment type. Users can enter the service type and cost, and upon saving,
 the data is stored in Core Data. If an appointment type is being edited, the existing values are pre-populated in the text fields.
 */
class addNewServiceViewController: UIViewController {
    
    var serviceToEdit: AppointmentType?
    
    var managedObjectContext: NSManagedObjectContext!

    @IBOutlet weak var serviceCost: UITextField!
    @IBOutlet weak var serviceType: UITextField!
    
    
    //function to save the appointment type to CoreData
    @IBAction func saveAppointmentType(_ sender: Any) {
        guard let this_serviceType = serviceType.text, !this_serviceType.isEmpty else {
            displayMessage(title: "Error", message: "Service Type is invalid")
            return
        }
        
        guard let this_serviceCost = serviceCost.text, !this_serviceCost.isEmpty, this_serviceCost != "$", this_serviceCost != "0" else {
            displayMessage(title: "Error", message: "Service Cost is invalid")
            return
        }
        if let service = serviceToEdit{
            service.type = this_serviceType
            service.cost = this_serviceCost
        }
        else{
            let this_appointmentType = AppointmentType(context: managedObjectContext)
            this_appointmentType.type = this_serviceType
            this_appointmentType.cost = this_serviceCost
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
        serviceCost.text = "$"
        
        if serviceToEdit != nil{
            serviceType.text = serviceToEdit?.type
            serviceCost.text = serviceToEdit?.cost
        }
        // Do any additional setup after loading the view.
        serviceCost.addDoneButton()
        serviceType.addDoneButton()
    }


}
