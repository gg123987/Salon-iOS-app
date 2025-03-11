//
//  BusinessInfoViewController.swift
//  Assignment
//
//  Created by Gabi Franck on 6/6/2023.
//

import UIKit

/**
 This  class manages the user interface for entering and saving business information. It retrieves and displays previously saved
 business name and owner name. When the user saves the details, it validates the input and stores the information in UserDefaults.
 */
class BusinessInfoViewController: UIViewController {

    @IBOutlet weak var businessName: UITextField!
    
    @IBOutlet weak var ownerName: UITextField!
    
    let userDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        businessName.addDoneButton()
        ownerName.addDoneButton()
            
        if userDefaults.object(forKey: "business name") != nil{
            let thisBusinessName = userDefaults.string(forKey: "business name")
            let thisOwnerName = userDefaults.string(forKey: "owner name")
            
            businessName.text = thisBusinessName
            ownerName.text = thisOwnerName
        }
    }
    
    //function to save the business details to User Defaults
    @IBAction func saveBusinessDetails(_ sender: Any) {
        
        if businessName.text?.isEmpty ?? true || ownerName.text?.isEmpty ?? true {
            displayMessage(title: "Error", message: "Please enter all fields")
        }
        else{
            let thisBusinessName = businessName.text
            let thisOwnerName = ownerName.text
            userDefaults.set(thisBusinessName, forKey: "business name")
            userDefaults.set(thisOwnerName, forKey: "owner name")
            navigationController?.popViewController(animated: true)
        }
    }

}
