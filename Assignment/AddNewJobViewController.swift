//
//  AddNewJobViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 29/5/2023.
//

import UIKit
import CoreData


/**
 This class is responsible for adding new jobs or editing existing jobs. It allows users to choose a client and job type from a list, enter a quote,
 select drop-off and pickup dates, and indicate whether the job is complete. When saving the job, it updates the Core Data entities accordingly.
 The view controller also implements delegate methods to receive the selected client and appointment type from popover view controllers.
 */
class AddNewJobViewController: UIViewController, ClientsPopoverDelegate, AppointmentsPopoverDelegate {
    
    var jobToEdit: Job?
    
    var thisCLient: Client? = nil
    
    var thisJobType: AppointmentType? = nil
    
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak var clientChosen: UILabel!
    
    @IBOutlet weak var jobTypeChosen: UILabel!
    
    
    @IBOutlet weak var quote: UITextField!
    
    @IBOutlet weak var dropoff_date: UIDatePicker?
    
    
    @IBOutlet weak var pickup_date: UIDatePicker?
    
    @IBOutlet weak var isJobComplete: UISwitch?
    
    //choosing a client
    @IBAction func chooseClient(_ sender: Any) {
        performSegue(withIdentifier: "showClientslistJobsSegue", sender: nil)
    }
    
    //choosing a job type
    @IBAction func chooseJobType(_ sender: Any) {
        performSegue(withIdentifier: "showAppointmentTypeJobsSegue", sender: nil)
    }
    
    //saving the job to CoreData
    @IBAction func saveNewJob(_ sender: Any) {
        
        var isDone = "false"
        if isJobComplete!.isOn {
            isDone = "true"
        }
        
        let client: Client
        let jobType: AppointmentType
        
        if let existingJob = jobToEdit {
            // Editing an existing job
            if let existingClient = thisCLient {
                client = existingClient
            } else {
                client = existingJob.job_client!
            }
            
            if let existingJobType = thisJobType {
                jobType = existingJobType
            } else {
                jobType = existingJob.job_appointmentType!
            }
            
            existingJob.job_client = client
            existingJob.job_appointmentType = jobType
            existingJob.pickup_date = pickup_date?.date
            existingJob.dropoff_date = dropoff_date?.date
            existingJob.quote = quote.text
            existingJob.isComplete = isDone
        } else {
            // Creating a new job
            guard let newClient = thisCLient,
                  let newJobType = thisJobType,
                  let quoteText = quote.text,
                  let dropoff = dropoff_date?.date,
                  let pickup = pickup_date?.date else {
                return
            }
            
            client = newClient
            jobType = newJobType
            
            let newJob = Job(context: managedObjectContext)
            newJob.job_client = client
            newJob.job_appointmentType = jobType
            newJob.pickup_date = pickup
            newJob.dropoff_date = dropoff
            newJob.quote = quoteText
            newJob.isComplete = isDone
        }
        
        do {
            try managedObjectContext.save()
            navigationController?.popViewController(animated: true)
        } catch {
            // Handle error
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if jobToEdit != nil {
            if thisCLient != nil {
                clientChosen.text = thisCLient?.name
            }
            else{
                clientChosen.text = jobToEdit?.job_client?.name
            }
            if thisJobType != nil{
                jobTypeChosen.text = thisJobType?.type
            }
            else{
                jobTypeChosen.text = jobToEdit?.job_appointmentType?.type
            }
            
            quote.text = jobToEdit?.quote
            dropoff_date?.setDate((jobToEdit?.dropoff_date)!, animated: true)
            pickup_date?.setDate((jobToEdit?.pickup_date)!, animated: true)
            if jobToEdit?.isComplete == "true"{
                isJobComplete?.isOn = true
            }
            else{
                isJobComplete?.isOn = false
            }
        }
        else{
            if thisCLient != nil{
                clientChosen.text = thisCLient?.name
            }else{
                clientChosen.text = "Please select a client"
            }
            
            if thisJobType != nil{
                jobTypeChosen.text = thisJobType?.type
            }else{
                jobTypeChosen.text = "Please select Job Type"
            }
        }
        
        quote.addDoneButton()
    }
    
    //delegate method to set the client chosen
    func didSelectClient(_ client: Client) {
        thisCLient = client
    }
    
    //delegate method to set the appointment type
    func didSelectAppointmentType(_ appointmentType: AppointmentType){
        thisJobType = appointmentType
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showClientslistJobsSegue"{
            let clientsPopoverVC = segue.destination as! ClientsPopoverTableViewController
            clientsPopoverVC.delegate = self
        }
        if segue.identifier == "showAppointmentTypeJobsSegue"{
            let appointmentTypeVC = segue.destination as! AppointmentsPopoverTableViewController
            appointmentTypeVC.delegate = self
        }
        
    }
    

}
