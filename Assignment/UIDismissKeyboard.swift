//
//  UIDismissKeyboard.swift
//  Assignment
//
//  Created by Gabi Franck on 17/5/2023.
//

import Foundation
import UIKit

/**
 Extension to add a Done button to all keyboards to dismiss them
 */
extension UITextField {
    func addDoneButton() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.resignFirstResponder))
        
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.inputAccessoryView = keyboardToolbar
        
        //self.returnKeyType = .done
    }
}


