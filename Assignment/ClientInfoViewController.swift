//
//  ClientInfoViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 10/5/2023.
//

import UIKit
import CoreData
import MessageUI


/**
 This class is responsible for displaying the details of a client, including their name, phone number, and email address. It allows the user to edit the
 client's information by segueing to the AddNewClientViewController with the client data. The class also provides additional functionality, such as
 dialing the client's phone number and sending an email to the client using the device's email capabilities.
 */
class ClientInfoViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var phoneLabel: UILabel!
    
    
    @IBOutlet weak var emailLabel: UILabel!
    
    var this_client: Client!
    
    var managedObjectContext: NSManagedObjectContext!
    
    //function to go to being able to edit the client
    @IBAction func editClient(_ sender: Any) {
        performSegue(withIdentifier: "editClientInfoSegue", sender: this_client)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        nameLabel.text = this_client.name
        phoneLabel.text = this_client.phone
        if this_client.email == ""{
            emailLabel.text = "No email provided"
        }
        else{
            emailLabel.text = this_client.email
        }
        
        // enable user interaction with the phoneLabel
        phoneLabel.isUserInteractionEnabled = true
        let phoneTapGesture = UITapGestureRecognizer(target: self, action: #selector(dialPhoneNumber(_:)))
        phoneLabel.addGestureRecognizer(phoneTapGesture)
        
        
        if this_client.email == ""{}
        else{
            // enable user interaction with emailLabel
            emailLabel.isUserInteractionEnabled = true
            let emailTapGesture = UITapGestureRecognizer(target: self, action: #selector(emailLabelTapped))
            emailLabel.addGestureRecognizer(emailTapGesture)
        }
    }
    
    //function to dial the clients phone number and make a call in app
    @objc func dialPhoneNumber(_ sender: UITapGestureRecognizer){
        guard let phoneNumber = (sender.view as? UILabel)?.text else{
            return
        }
        if let phoneURL = URL(string: "tel://\(phoneNumber)"){
            if UIApplication.shared.canOpenURL(phoneURL) {
                UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
            } else {
                print("Unable to dial phone number: \(phoneNumber)")
            }
        }
    }
    
    //this function we retrieve the email address from the label and it will check if the device is able to send
    //emails. If it can we create an instance of MFMailComposeViewController, set the email recipient and present the VC.
    @objc func emailLabelTapped() {
            guard let emailAddress = emailLabel.text else {
                return
            }
            
            if MFMailComposeViewController.canSendMail() {
                let mailComposeVC = MFMailComposeViewController()
                mailComposeVC.mailComposeDelegate = self
                mailComposeVC.setToRecipients([emailAddress])
                
                present(mailComposeVC, animated: true, completion: nil)
            } else {
                // Handle the case where the device cannot send emails
                // You can show an alert or take any other appropriate action
                print("This device is unable to send emails")
            }
    }
    
    //ability to dismiss the email view
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editClientInfoSegue" {
            let destinationVC = segue.destination as! AddNewClientViewController
            destinationVC.clientToEdit = this_client
            destinationVC.managedObjectContext = managedObjectContext
        }
    }
    

}
