//
//  AppointmentInfoViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 27/4/2023.
//

import UIKit
import GoogleAPIClientForREST
import MessageUI
import GoogleSignIn

/**
 This class is responsible for displaying appointment details such as title, location, date, time,
 client name, and appointment type. It allows the user to send reminders to clients via WhatsApp or SMS.
 Additionally, it provides the ability to delete appointments from the Google Calendar API.
 */
class AppointmentInfoViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var event: GTLRCalendar_Event?
    
    @IBOutlet weak var appointmentTitle: UILabel!
    
    @IBOutlet weak var appointmentLocation: UILabel!
    
    @IBOutlet weak var appointmentDate: UILabel!
    
    @IBOutlet weak var appointmentTime: UILabel!
    
    @IBOutlet weak var clientName: UILabel!
    
    
    @IBOutlet weak var appointmentType: UILabel!
    
    //function to run when the user chooses to send a reminder. There are two options:
    //  1) sending a reminder via WhatsApp
    //  2) sending a reminder via SMS
    @IBAction func sendReminderButton(_ sender: Any) {
        
        let this_client = self.findClient(name: (self.event?.attendees![0].displayName)!)
        let name = this_client.name!
        let startObject = self.event?.start?.dateTime?.date
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let startTime = formatter.string(from: startObject!)
        let messageText = "Hello \(name).\nReminder that you have an appointment today at \(startTime).\nSee you then!"
        
        let alertController = UIAlertController(title: "Popup Alert", message: "Choose an option", preferredStyle: .alert)
        // Create the first action: Sending via WhatsApp
        let action1 = UIAlertAction(title: "Send WhatsApp", style: .default) { _ in
           
            var formattedPhoneNumber = this_client.phone!
            formattedPhoneNumber.remove(at: formattedPhoneNumber.startIndex)
            formattedPhoneNumber.insert(contentsOf: "61", at: formattedPhoneNumber.startIndex)
            
            self.sendWhatsAppTo(number: formattedPhoneNumber, message: messageText)
        }
        
        // Create the second action: Sending via SMS
        let action2 = UIAlertAction(title: "Send SMS", style: .default) { _ in
            self.sendSMSTo(number: this_client.phone!, message: messageText, viewController: self)
        }
        
        // Create the cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Handle cancel
            print("Cancel selected")
        }
        
        // Add the actions to the alert controller
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(cancelAction)
        
        // Configure the alert controller's appearance
        alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.systemBackground
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    //this function handles the ability to delete an appointment from the Google calendar API
    @IBAction func deleteButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Confirmation", message: "ARe you sure you want to delte this appointment?", preferredStyle: .alert)
        
        // Create the "Cancel" action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        
        // Create the "Yes" action
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.deleteAppointment(eventId: (self.event?.identifier)!)
            self.navigationController?.popViewController(animated: true)
        }
        
       
        // Add actions to the alert
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        
        
        // Present the alert
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //setting title
        appointmentTitle.text = event?.summary
        
        //setting the location
        if event?.location == nil{
            appointmentLocation.text = "No location provided"
        }else{
            appointmentLocation.text = event?.location
        }
        
        //setting the time and date features
        if let start = event?.start?.dateTime?.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            appointmentTime.text = formatter.string(from: start)
            formatter.dateFormat = "EEEE, MMM d, yyyy"
            appointmentDate.text = formatter.string(from: start)
        } else {
            appointmentTime.text = "All Day Event"
            appointmentDate.text = "All Day Event"
        }
        
        
        
        //setting client name
        if let attendeeObject = event?.attendees as? [GTLRCalendar_EventAttendee]{
            for attendee in attendeeObject {
                clientName.text = attendee.displayName
                break
            }
        }else{
            clientName.text = "No Client Invited"
        }
        
        //setting appointment type
        appointmentType.text = event?.descriptionProperty
    }
    
    //function to actually send the SMS
    func sendSMSTo(number: String, message: String, viewController: UIViewController) {
        if MFMessageComposeViewController.canSendText() {
            let messageComposeVC = MFMessageComposeViewController()
            messageComposeVC.recipients = [number]
            messageComposeVC.body = message
            messageComposeVC.messageComposeDelegate = viewController as? MFMessageComposeViewControllerDelegate
            
            viewController.present(messageComposeVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "SMS Not Supported", message: "Your device does not support SMS messaging.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    //function to actually send a whatsapp
    func sendWhatsAppTo(number: String, message: String){
        let urlWhatsApp = "https://wa.me/\(number)/?text=\(message)"
        if let urlString = urlWhatsApp.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed){
            if let whatsappURL = NSURL(string: urlString){
                if UIApplication.shared.canOpenURL(whatsappURL as URL){
                    UIApplication.shared.open(whatsappURL as URL, options: [:], completionHandler: nil)
                }
                else{
                    print("Cannot open WhatsApp")
                }
            }
        }
    }
    
    //function to find and return a client from CoreData from a client name
    func findClient(name: String) -> Client{
        var allClients: [Client] = []
        var thisClient: Client?
        do {
            let initialList = try context.fetch(Client.fetchRequest())
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
            allClients = (initialList as NSArray).sortedArray(using: [sortDescriptor]) as! [Client]
        } catch {
            //error
        }
        for client in allClients{
            if client.name == name{
                thisClient = client
                break
            }
        }

        return thisClient!
    }
    
    //function to handle dismissing the SMS view controller
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil) // Dismiss the SMS view controller
    }
    
    //function to actuallt delete the appointment from the API
    func deleteAppointment(eventId: String){
        // Create a service object for the Google Calendar API
        let service = GTLRCalendarService()
        service.authorizer = GIDSignIn.sharedInstance().currentUser?.authentication.fetcherAuthorizer()

        // Create a delete request
        let deleteRequest = GTLRCalendarQuery_EventsDelete.query(withCalendarId: "primary", eventId: eventId)

        // Execute the delete request
        service.executeQuery(deleteRequest) { (ticket, result, error) in
            if let error = error {
                print("Error deleting event: \(error.localizedDescription)")
                return
            }
            print("Event deleted successfully.")
        }
    }

}
