//
//  NewAppointmentsViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 4/5/2023.
//

import UIKit
import GoogleAPIClientForREST


/**
 This class is responsible for allowing users to create new appointments. It integrates with the Google Calendar API to save appointments to the user's Google Calendar.
 Users can enter details such as appointment title, location, date, time, client, and appointment type. The class provides methods for saving the appointment, choosing a
 client and appointment type, and handles the communication with the Google Calendar API for event creation.
 */
class NewAppointmentsViewController: UIViewController, ClientsPopoverDelegate, AppointmentsPopoverDelegate, UITextFieldDelegate {
    

    var service: GTLRCalendarService?
    
    // Your Google Calendar API calendar ID
    let calendarID = "primary"
    
    //client for the appointment
    var thisCLient: Client? = nil
    
    //appointment type
    var thisAppointmentType: AppointmentType? = nil
    

    @IBOutlet weak var appointmentTitle: UITextField!
    
    @IBOutlet weak var appointmentLocation: UITextField!


    @IBOutlet weak var appointmentDateTime: UIDatePicker!
    @IBOutlet weak var appointmentTypeChosen: UILabel!
    @IBOutlet weak var clientChosen: UILabel!
    
    //function to save the new appointment to the API
    @IBAction func saveNewEvent(_ sender: Any) {
        var email = ""
        if thisCLient?.email == ""{
             email = "fake@gmail.com"
        }
        else{
            email = (thisCLient?.email)!
        }
        let newEvent = createEvent(title: appointmentTitle.text!, location: appointmentLocation.text!, dateAndTime: appointmentDateTime.date, clientName: (thisCLient?.name)!, clientEmail: email, appointmentType: (thisAppointmentType?.type)!)
        print(newEvent)
        Task{
            try await push(event: newEvent)
            
            let alertController = UIAlertController(title: "Success", message: "Appointment added successfully", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    //ability to choose a client
    @IBAction func chooseClient(_ sender: Any) {
        performSegue(withIdentifier: "showClientListPopoverSegue", sender: nil)
    }
    
    //ability to choose the appointment type
    @IBAction func chooseAppointmentType(_ sender: Any) {
        performSegue(withIdentifier: "chooseAppointmentTypeAppointmentSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appointmentTitle.addDoneButton()
        appointmentLocation.addDoneButton()
        
        if thisCLient != nil{
            clientChosen.text = thisCLient?.name
        }else{
            clientChosen.text = "Please select a client"
        }
        
        if thisAppointmentType != nil{
            appointmentTypeChosen.text = thisAppointmentType?.type
        }else{
            appointmentTypeChosen.text = "Please select Appointment Type"
        }
    }
    
    
    //Pushing the new event to the API
    func push(event: GTLRCalendar_Event) async throws -> GTLRCalendar_Event? {
        let query = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: calendarID)
        do {
            return try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<GTLRCalendar_Event?, Error>) in
                service?.executeQuery(query) { (ticket, createdEvent, error) in
                    if let error = error {
                        print("Error: \(error)")
                        continuation.resume(throwing: error)
                    } else {
                        let calendar_event: GTLRCalendar_Event = createdEvent.unsafelyUnwrapped as! GTLRCalendar_Event
                        continuation.resume(returning: calendar_event)
                    }
                }
            }
        } catch {
            print("Error: \(error)")
            throw error
        }
    }
    
    //creating the event and returning a GTRCalendar_Event
    func createEvent(title: String, location: String, dateAndTime: Date, clientName: String, clientEmail: String, appointmentType: String) -> GTLRCalendar_Event {
        let event = GTLRCalendar_Event()

        // Set the event title
        event.summary = title

        // Set the event location
        event.location = location

        // Set the event start time
        let startObj = GTLRCalendar_EventDateTime()
        startObj.dateTime = GTLRDateTime(date: dateAndTime)
        event.start = startObj
        
        // Set the event end time (30 mins after the start time)
        let endDateTime = dateAndTime.addingTimeInterval(30 * 60)
        let endObj = GTLRCalendar_EventDateTime()
        endObj.dateTime = GTLRDateTime(date: endDateTime)
        event.end = endObj
        
        let newAttendee =  GTLRCalendar_EventAttendee()
        newAttendee.displayName = clientName
        newAttendee.email = clientEmail
        event.attendees = [newAttendee]
        
        event.descriptionProperty = appointmentType
        
        return event
    }
    
    //function to convert a Date object to a string
    func convertDateObjectToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    //delegate function to set the client
    func didSelectClient(_ client: Client) {
        thisCLient = client
    }
    
    //delegate function to set the appointment type
    func didSelectAppointmentType(_ appointmentType: AppointmentType){
        thisAppointmentType = appointmentType
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showClientListPopoverSegue"{
            let clientsPopoverVC = segue.destination as! ClientsPopoverTableViewController
            clientsPopoverVC.delegate = self
        }
        if segue.identifier == "chooseAppointmentTypeAppointmentSegue"{
            let appointmentTypeVC = segue.destination as! AppointmentsPopoverTableViewController
            appointmentTypeVC.delegate = self
        }
        
    }


}
