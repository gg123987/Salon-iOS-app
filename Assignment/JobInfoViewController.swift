//
//  JobInfoViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 29/5/2023.
//

import UIKit
import CoreData
import PDFKit
import WebKit

/**
 This class displays detailed information about a job, including the client, job type, quote, dates, and completion status.
 Users can edit the job or generate a PDF invoice depending on its completion status.
 */
class JobInfoViewController: UIViewController, WKNavigationDelegate {
    
    var this_job: Job!
    
    var managedObjectContext: NSManagedObjectContext!

    @IBOutlet weak var clientChosen: UILabel!
    
    @IBOutlet weak var jobChosen: UILabel!
    
    
    @IBOutlet weak var quote: UILabel!
    
    
    @IBOutlet weak var dropOff: UILabel!
    
    @IBOutlet weak var pickup: UILabel!
    
    
    @IBOutlet weak var completed: UILabel!
    
    //button to edit the selected job
    @IBAction func editJob(_ sender: Any) {
        performSegue(withIdentifier: "editJobSegue", sender: this_job)
    }
    
    @IBOutlet weak var jobButton: UIButton!

    //the button for this job. Depending of the job is done or not, it is
    //either set to generate a PDF invoice, or to mark the job as done.
    @IBAction func jobButtonAction(_ sender: Any) {
        
        if this_job.isComplete == "false"{
            this_job.isComplete = "true"
            do {
                try managedObjectContext.save()
            } catch {
                // Handle the error here
                print("Error saving managed object context: \(error)")
            }
            navigationController?.popViewController(animated: true)
        }
        else{
            performSegue(withIdentifier: "generatePDFSegue", sender: this_job)
        }
 
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        clientChosen.text = this_job.job_client?.name
        jobChosen.text = this_job.job_appointmentType?.type
        quote.text = this_job.quote
        
        let dropoff_date = this_job.dropoff_date
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        dropOff.text = formatter.string(from: dropoff_date!)
        
        let pickup_date = this_job.pickup_date
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        pickup.text = formatter.string(from: pickup_date!)
        
        if this_job.isComplete == "false"{
            completed.text = "Not Done"
        }
        else{
            completed.text = "Done"
        }
        if this_job.isComplete == "true"{
            jobButton.setTitle("GENERATE INVOICE", for: .normal)
        }
        else{
            jobButton.setTitle("MARK AS COMPLETE", for: .normal)
        }

    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editJobSegue" {
            let destinationVC = segue.destination as! AddNewJobViewController
            destinationVC.jobToEdit = this_job
            destinationVC.managedObjectContext = managedObjectContext
        }
        else if segue.identifier == "generatePDFSegue"{
            let destinationVC = segue.destination as! PDFViewController
            destinationVC.thisJob = sender as? Job
        }
    }
    

}

