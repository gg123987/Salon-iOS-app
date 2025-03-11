//
//  JobsTableViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 29/5/2023.
//

import UIKit

/**
 This class handels displaying a list of completed jobs in a table view. It fetches the job data from Core Data, populates the table cells with
 client names and appointment types. Completed jobs have a green background, and users can delete jobs. Tapping on a job cell segues
 to a detailed view, and there's a segue to add new jobs.
 */
class JobsTableViewController: UITableViewController {
    
    
    @IBOutlet var jobsTableView: UITableView!
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var completedJobsList: [Job] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllJobs()
        jobsTableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return completedJobsList.count
    }

    //setting the cells with jobs
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath)
        let job = completedJobsList[indexPath.row]
        cell.textLabel?.text = job.job_client?.name
        cell.detailTextLabel?.text = job.job_appointmentType?.type
        if job.isComplete == "true"{
            cell.backgroundColor = UIColor.green
        }
        else{
            cell.backgroundColor = nil
        }
        return cell
    }
    
    //fetching all jobs from CoreData
    func getAllJobs(){
        do {
            let initialList = try context.fetch(Job.fetchRequest())
            let sortDescriptor = NSSortDescriptor(key: "isComplete", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
            completedJobsList = (initialList as NSArray).sortedArray(using: [sortDescriptor]) as! [Job]
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
            let this_job = completedJobsList[indexPath.row]
            let alert = UIAlertController(title: "Are you sure?", message: "Deleting this job will remove all of its data.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                self.context.delete(this_job)
                do {
                    try self.context.save()
                    self.completedJobsList.remove(at: indexPath.row)
                    self.jobsTableView.deleteRows(at: [indexPath], with: .fade)
                } catch{
                    //error
                }
            }))
            present(alert, animated: true)
        }
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedJob = completedJobsList[indexPath.row]
        performSegue(withIdentifier: "showJobDetailsSegue", sender: selectedJob)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addJobSegue" {
            let addJobVC = segue.destination as! AddNewJobViewController
            addJobVC.managedObjectContext = context
        }
        else if segue.identifier == "showJobDetailsSegue" {
            let destinationVC = segue.destination as! JobInfoViewController
            destinationVC.this_job = sender as? Job
            destinationVC.managedObjectContext = context
        }
        
    }
    

}
