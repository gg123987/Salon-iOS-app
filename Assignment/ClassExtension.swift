//
//  ClassExtension.swift
//
//  Created by Gabi Franck on 2/3/2023.
//

import UIKit
/**
 Extension to allow for diplaying messages as UIAlerts
 */
extension UIViewController {
    func displayMessage(title:String, message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
