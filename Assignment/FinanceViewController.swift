//
//  FinanceView.swift
//  Assignment
//
//  Created by Gabi Franck on 27/4/2023.
//

import UIKit
import SwiftUI
import Charts
import CoreData

/**
This class is responsible for the finance view in the application. It displays completed jobs
in a table view, provides filtering options for different time periods, calculates and shows
earnings, and visualizes the earnings data using a chart.
*/
class FinanceViewController: UIViewController,UITableViewDataSource {


    @IBOutlet weak var jobsTableView: UITableView!
    
    @IBOutlet weak var chartUIView: UIView!
    
    @IBOutlet weak var filterPopup: UIButton!
    
    //function to show the earning from the displayed jobs
    @IBAction func showEarnings(_ sender: Any) {
        
        var totalEarnings: Decimal = 0

        for job in completedJobsList {
            if let quote = job.quote {
                var earningsString = ""
                if quote.hasPrefix("$"){
                    earningsString = quote.replacingOccurrences(of: "$", with: "") // Remove the "$" sign
                }
                else{
                    earningsString = quote
                }
                if let earnings = Decimal(string: earningsString) {
                    totalEarnings += earnings
                }
            }
        }
        displayMessage(title: "Total Earnings", message: "The total amount earned in the below period is $\(totalEarnings)")
        
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var completedJobsList: [Job] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getAllCompletedJobs()

        jobsTableView.reloadData()
        jobsTableView.dataSource = self
        setPopupButton()
        loadChart()
        
    }
    
    //function to fetch all jobs that are completed from CoreData
    func getAllCompletedJobs() {
        do {
            let fetchRequest: NSFetchRequest<Job> = Job.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isComplete == %@", "true")
            
            let initialList = try context.fetch(fetchRequest)
            let sortDescriptor = NSSortDescriptor(key: "isComplete", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
            completedJobsList = (initialList as NSArray).sortedArray(using: [sortDescriptor]) as! [Job]
        } catch {
            // Handle error
        }
    }
    
    //This function setPopupButton() defines four different actions for a popup button.
    func setPopupButton(){
        //action to show all complated jobs
        let all = {(action: UIAction) in
            self.getAllCompletedJobs()
            self.jobsTableView.reloadData()
            self.loadChart()
        }
        //action to show all jobs that were completed int he last week
        let lastWeek = {(action: UIAction) in
            self.getAllCompletedJobs()
            // Get the current date
            let currentDate = Date()

            // Calculate the date range for the last week
            let calendar = Calendar.current
            let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate)!

            // Filter the completed jobs list based on the pickup date
            let filteredJobs = self.completedJobsList.filter { job in
                guard let pickupDate = job.pickup_date else {
                    return false
                }
                return pickupDate >= oneWeekAgo && pickupDate <= currentDate
            }
            self.completedJobsList = filteredJobs
            self.jobsTableView.reloadData()
            self.loadChart()
        }
        //action to show all jobs that were completed in the last month
        let lastMonth = {(action: UIAction) in
            self.getAllCompletedJobs()
            // Get the current date
            let currentDate = Date()
            
            // Calculate the date range for the last month
            let calendar = Calendar.current
            let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: currentDate)!
            
            // Filter the completed jobs list based on the pickup date
            let filteredJobs = self.completedJobsList.filter { job in
                guard let pickupDate = job.pickup_date else {
                    return false
                }
                let isIn = pickupDate >= oneMonthAgo && pickupDate <= currentDate
                return isIn
            }
            self.completedJobsList = filteredJobs
            self.jobsTableView.reloadData()
            self.loadChart()
        }
        //action to show all jobs that were completed in the last year
        let lastYear = {(action: UIAction) in
            self.getAllCompletedJobs()
            // Get the current date
            let currentDate = Date()

            // Calculate the date range for the last year
            let calendar = Calendar.current
            let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: currentDate)!

            // Filter the completed jobs list based on the pickup date
            let filteredJobs = self.completedJobsList.filter { job in
                guard let pickupDate = job.pickup_date else {
                    return false
                }
                return pickupDate >= oneYearAgo && pickupDate <= currentDate
            }
            self.completedJobsList = filteredJobs
            self.jobsTableView.reloadData()
            self.loadChart()
        }
        
        //diplaying the options
        filterPopup.menu = UIMenu(children:[
            UIAction(title: "Show all",state: .on, handler: all),
            UIAction(title: "Show Last Week", handler: lastWeek),
            UIAction(title: "Show Last Month", handler: lastMonth),
            UIAction(title: "Show Last Year", handler: lastYear)])
        
        filterPopup.showsMenuAsPrimaryAction = true
        filterPopup.changesSelectionAsPrimaryAction = true
    }

    //setting the table length
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completedJobsList.count
    }
    
    //setting the individual cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobTableViewCell
        let job = completedJobsList[indexPath.row]
        cell.nameLabel.text = job.job_client?.name
        cell.priceLabel.text = job.quote
        
        return cell
    }
    
    //loaing the chart onto the view
    func loadChart(){
        let controller = UIHostingController(rootView: ChartUIView(jobs: completedJobsList))
        guard let chartView = controller.view else {
            return
        }
        chartUIView.addSubview(chartView)
        addChild(controller)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.0),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12.0),
            chartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0.0),
            chartView.widthAnchor.constraint(equalTo: chartView.heightAnchor, constant: 20.0)
        ])
    }
}

//a struct to hold the data for the table
struct FinanceDataStructure: Identifiable {
    var id = UUID()
    var date: Date
    var moneyEarned: Double
    var xAxisString: String
}

//a struc to construct the chart
struct ChartUIView: View{

    //all data points for the chart
    var job_list: [FinanceDataStructure] = []

    //initialiser
    init(jobs: [Job]) {
        //looping through all the jobs that are passed into the initialiser
        for job in jobs {
            
            var isFound = false
            //checking if the job we are adding to the chart is already in the list
            for var data in job_list{
                if Calendar.current.isDate(data.date, equalTo: job.dropoff_date!, toGranularity: .day) && Calendar.current.isDate(data.date, equalTo: job.dropoff_date!, toGranularity: .month){
                    let moneyString = job.quote!.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
                    let moneyDouble = Double(moneyString)!
                    data.moneyEarned = data.moneyEarned + moneyDouble
                    isFound = true
                    break
                }
            }
            if !isFound{
                let newDate = job.dropoff_date!
                
                let moneyString = job.quote!.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
                let moneyDouble = Double(moneyString)!
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                
                let newDateData = FinanceDataStructure(date: newDate, moneyEarned: moneyDouble, xAxisString: "\(dateFormatter.string(from: newDate))")
                job_list.append(newDateData)
            }
            
        }
    }
    //setting the chart
    var body: some View {
        Chart(job_list) { jobData in
            LineMark(x: .value("Date", "\(jobData.xAxisString)"), y: .value("Money", jobData.moneyEarned))
        }
    }
}




