//
//  AppointmentsViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 27/4/2023.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

import UserNotifications


/**
This class is responsible for controlling the functionality of the Appointments feature.
It implements the following features:
    1: Google Sign-In: The code integrates Google Sign-In functionality using the GoogleSignIn framework.
       It handles user sign-in and obtains the necessary authorization for accessing the Google Calendar API.
    2: Calendar View: The code creates a custom calendar view using UICalendarView to display dates.
       It sets up the calendar's appearance, delegate, and selection behavior. The calendar uses Google Calendar API
       to display the appointments scheduled on that day
    3: Table View: The code sets up the table view to display the fetched appointments. It implements the data source
       methods to populate the table view cells with appointment details and the delegate method to handle row selection.
    4: Creating Appointments: The code includes a segue to navigate to a view controller for creating new appointments.
       It passes the necessary data, such as the Google Calendar service object, to the destination view controller.
    5: Notifications: The code provides functionality to set notifications for the selected date's appointments.
*/
class AppointmentsViewController: UIViewController, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {

    
    
    @IBOutlet weak var appointmentTableView: UITableView!
    
    var selectedDate: Date?
    var currentDate = Date()
    // The Google Calendar API service object for making requests
    var service: GTLRCalendarService?
    // Events array to hold events for the selected day
    var allEvents: [GTLRCalendar_Event] = []
    // Your Google API client ID
    //let clientID = REDACTED
    // Your Google Calendar API scope
    let calendarScope = "https://www.googleapis.com/calendar/v3/"
    // Your Google API key
    //let APIKey = REDACTED
    // Your Google Calendar API calendar ID
    let calendarID = "primary"
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    @IBOutlet weak var storyboardCalendarView: UIView!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // sign in to google
        Task{
            await signIn()
        }
        
        if !(storyboardCalendarView.subviews.isEmpty){
            let thisView = storyboardCalendarView.subviews[0]
            thisView.removeFromSuperview()
        }
        //create calendar view
        createCalendar()
        
        //setup the tableview delegate and data source
        appointmentTableView.delegate = self
        appointmentTableView.dataSource = self
        
        allEvents = []
        appointmentTableView.reloadData()
        
    }
    

    //create the calendar view and add it to the storyboardCalendarView
    func createCalendar(){
        let calendarView = UICalendarView()
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        calendarView.calendar = .current
        calendarView.locale = .current
        calendarView.fontDesign = .rounded
        calendarView.delegate = self
        
        
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
        
        //add the calendar to the view in the UI
        storyboardCalendarView.addSubview(calendarView)
                
    }
    
    //jump to create a new appointment when the create appointment button is tapped
    @IBAction func createNewAppointmentButton(_ sender: Any) {
        performSegue(withIdentifier: "newAppointmentSegue", sender: service)
    }
    
    //return a decrative for a date in the calendar
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        return nil
    }
    

    //handle the date selection in the Calendar View
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        selectedDate = (dateComponents?.date)!
        
        Task{
            allEvents = await fetch(startDate: selectedDate!)
            appointmentTableView.reloadData()
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewAppointmentInfoSegue" {
            if let destinationVC = segue.destination as? AppointmentInfoViewController, let selectedEvent = sender as? GTLRCalendar_Event {
                destinationVC.event = selectedEvent
            }
        }
        else if segue.identifier == "newAppointmentSegue" {
            if let destinationVC = segue.destination as? NewAppointmentsViewController, let calendarService = sender as? GTLRCalendarService{
                destinationVC.service = calendarService
            }
        }
    }
    
    //function to set local notifications for all appointments scheduled for the selected day
    @IBAction func setNotificationsForToday(_ sender: Any) {
        if selectedDate == nil{
            displayMessage(title: "Error", message: "No Date Selected")
        }
        else if isDateInPast(selectedDate!){
            displayMessage(title: "Error", message: "Please select the current date, or a day in the future")
        }
        else if !allEvents.isEmpty{
            let alertController = UIAlertController(title: "Notifications", message: "Would you like to set notifications for the selected date?", preferredStyle: .alert)
            // Action for "Yes"
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    self.dispatchNotifications()
            }))
            
            // Action for "No"
            alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
                // Dismiss the notification
                alertController.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            displayMessage(title: "Error", message: "No Appointments scheduled for the selected date")
        }
        
    }
    
}

//extension of this class to perform all other required functionalities of this View Controller
extension AppointmentsViewController: UITableViewDataSource, GIDSignInDelegate, GIDSignInUIDelegate, UITableViewDelegate {
    
    //number of items in the appointments table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEvents.count
    }
    
    //displaying the details of each appointment
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentCell", for: indexPath) as! AppointmentTableViewCell
        
        let event = allEvents[indexPath.row]
        cell.nameLabel.text = event.summary
        
        if let start = event.start?.dateTime?.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            cell.timeLabel.text = formatter.string(from: start)
        } else {
            cell.timeLabel.text = "All Day"
        }
        
        
        return cell
    }
    
    //handeling selecting a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedEvent = allEvents[indexPath.row]
        performSegue(withIdentifier: "viewAppointmentInfoSegue", sender: selectedEvent)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }

    //sign in function for signing into Google for use of the Google Calendar API
    func signIn() async {
        GIDSignIn.sharedInstance().clientID = self.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeCalendar]
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    //required function to handle the actual sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                    return
        }
        guard user.authentication != nil else {
            print("Authentication has failed")
            return
        }
        let calendarService = GTLRCalendarService()
        
        if let authentication = GIDSignIn.sharedInstance()?.currentUser?.authentication {
            calendarService.authorizer = authentication.fetcherAuthorizer()
            service = calendarService
        }
        else {
            print("User has not been signed in")
            return
        }
    }

    //function to fetch all the appointments on the given date
    func fetch(startDate: Date) async -> [GTLRCalendar_Event] {
        //setting up query
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarID)
        query.maxResults = 100

        let convertedDate = convertDate(date: startDate)

        query.timeMin = GTLRDateTime(rfc3339String: stringMinTime(dateString: convertedDate))
        query.timeMax = GTLRDateTime(rfc3339String: stringMaxTime(dateString: convertedDate))

        query.singleEvents = true

        query.orderBy = "startTime"

        //doing the actual fetching of the data
        do {
            return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<[GTLRCalendar_Event], Error>) in
                service?.executeQuery(query) { (ticket, events, error) in
                    if let error = error {
                        print("Error: \(error)")
                        continuation.resume(throwing: error)
                    } else {
                        let calendar_events: GTLRCalendar_Events = events.unsafelyUnwrapped as! GTLRCalendar_Events
                        continuation.resume(returning: calendar_events.items!)
                    }
                }
            }
        } catch {
            print("Error: \(error)")
            return []
        }

    }
    

    

    //function to convert a Date into a string
    func convertDate(date: Date) -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Australia/Sydney")!
    
        let returnString = formatter.string(from: date)
        
        return returnString
    }
        
    //function to change the time in the dateString to be 12:00am to be able to fetch all events from the start of the day
    func stringMinTime(dateString: String) -> String {
        var updatedString = dateString
        var index = updatedString.index(updatedString.startIndex, offsetBy: 11)
        updatedString.replaceSubrange(index...index, with: "0")
        index = updatedString.index(updatedString.startIndex, offsetBy: 12)
        updatedString.replaceSubrange(index...index, with: "0")
        index = updatedString.index(updatedString.startIndex, offsetBy: 14)
        updatedString.replaceSubrange(index...index, with: "0")
        index = updatedString.index(updatedString.startIndex, offsetBy: 15)
        updatedString.replaceSubrange(index...index, with: "0")

        return updatedString
    }
    
    //function to change the time in the dateString to be 11:59pm to be able to fetch all events until the end of the day
    func stringMaxTime(dateString: String) -> String {
        var updatedString = dateString
        var index = updatedString.index(updatedString.startIndex, offsetBy: 11)
        updatedString.replaceSubrange(index...index, with: "2")
        index = updatedString.index(updatedString.startIndex, offsetBy: 12)
        updatedString.replaceSubrange(index...index, with: "3")
        index = updatedString.index(updatedString.startIndex, offsetBy: 14)
        updatedString.replaceSubrange(index...index, with: "5")
        index = updatedString.index(updatedString.startIndex, offsetBy: 15)
        updatedString.replaceSubrange(index...index, with: "9")
        index = updatedString.index(updatedString.startIndex, offsetBy: 17)
        updatedString.replaceSubrange(index...index, with: "5")
        index = updatedString.index(updatedString.startIndex, offsetBy: 18)
        updatedString.replaceSubrange(index...index, with: "9")

        return updatedString
    }
    
    //function to send the notifications to the Notification Center
    func dispatchNotifications() {
        
        //checking if the user has granted permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                
                //looping through all events for the selected day to set notifications for them
                for event in self.allEvents{
                   let this_request = self.createCustomNotification(title: "Reminder: Appointment", body: event.summary!, date: (event.start?.dateTime)!, eventID: event.identifier!)
                   UNUserNotificationCenter.current().add(this_request, withCompletionHandler: nil)
                }
                
            }
            else {
                // Permission denied
                print("Notification permission denied")
            }
        }
        if self.allEvents.count == 0{
            self.displayMessage(title: "Message", message: "No notifications set")
        }
        else{
            self.displayMessage(title: "Success", message: "\(self.allEvents.count) Notifications set")
        }
    }


    //function to create the Notification
    func createCustomNotification(title: String, body: String, date: GTLRDateTime, eventID: String) -> UNNotificationRequest{
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let dateTime = convertGTLRDateTimeToDateComponents(dateTime: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateTime!, repeats: false)

        return UNNotificationRequest(identifier: eventID, content: content, trigger: trigger)
    }
    
    //function to convert a GTLR DateTime object to DateComponents
    func convertGTLRDateTimeToDateComponents(dateTime: GTLRDateTime) -> DateComponents? {
        let calendar = Calendar.current
        
        // Extract the individual components from the GTLRDateTime object
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateTime.date)
        
        return components
    }
    
    //function to check if a date is in the past
    func isDateInPast(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date())
        let compareDate = calendar.startOfDay(for: date)
        return compareDate < currentDate
    }
   
}




