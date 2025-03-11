//
//  ServiceInfoViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 29/5/2023.
//

import UIKit
import CoreData

/**
 This class is responsible for displaying the service details on the page. 
 */
class ServiceInfoViewController: UIViewController {

    var this_service: AppointmentType!
    
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak var serviceType: UILabel!
    
    @IBOutlet weak var serviceCost: UILabel!
    
    //button to edit the service
    @IBAction func editService(_ sender: Any) {
        performSegue(withIdentifier: "editServiceSegue", sender: this_service)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        serviceType.text = this_service.type
        serviceCost.text = this_service.cost
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editServiceSegue" {
            let destinationVC = segue.destination as! addNewServiceViewController
            destinationVC.serviceToEdit = this_service
            destinationVC.managedObjectContext = managedObjectContext
        }
    }
    

}
