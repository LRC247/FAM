//
//  StartingBalanceController.swift
//  FAMApp
//
//  Created by Rohit Krishnan on 8/23/18.
//  Copyright © 2018 Khyteang. All rights reserved.
//

import Foundation
import UIKit

class StartingBalanceController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var txtBalance: UITextField!
    var startingBalance: Double!
    var delegate: AddBalanceDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
        self.txtBalance.delegate = self
        if self.startingBalance != nil && self.startingBalance > 0 {
            self.startingBalance = round(100.0 * self.startingBalance) / 100.0
            self.txtBalance.text = String(self.startingBalance)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.txtBalance.becomeFirstResponder()
    }
    
    @IBAction func btnAddBalance(_ sender: Any) {
        let amount = self.txtBalance.text!
        if (amount == "") {
            let alertMessage = "Please enter a starting budget greater than $0.00."
            var alertController = UIAlertController(title: "Starting Budget", message: alertMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Will do", style: .default, handler: { _ in
                alertController.dismiss(animated: true, completion: {
                    
                })
            }))
        } else {
            self.delegate.onAddBalance(balance: Double(amount)!)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String)
    -> Bool {
        switch string {
        case "0","1","2","3","4","5","6","7","8","9":
            return true
        case ".":
            let array = Array(textField.text!)
            var decimalCount = 0
            for character in array {
                if character == "." {
                    decimalCount+=1
                }
            }
            
            if decimalCount == 1 {
                return false
            } else {
                return true
            }
        default:
            let array = Array(string)
            if array.count == 0 {
                return true
            }
            return false
        }
    }
    
}

protocol AddBalanceDelegate {
    func onAddBalance(balance: Double);
}
