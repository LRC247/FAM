//
//  ForgotPasswordController.swift
//  7030App
//
//  Created by Khyteang Lim on 10/8/18.
//  Copyright © 2018 Khyteang. All rights reserved.
//

import Firebase

class ForgotPasswordViewController: UIViewController {
 
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var requestPWBtn: UIButton!
    
    let alertTitle = "Password Reset"
    var alertMessage = "Email is required!"
    let alertBtnText = "OK"
    
    override func viewDidLoad() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
        super.viewDidLoad()
    }
    
    @IBAction func requestPasswordBtnPressed(_ sender: UIButton ) {
        let email:NSString = userEmail.text! as NSString
        if (email.isEqual(to: "")) {
            CreateAlert()
        } else {
            Auth.auth().sendPasswordReset(withEmail: email as String) { (error) in
                if (error != nil) {
                    self.alertMessage = "Error sending password reset!"
                    self.CreateAlert()
                } else {
                    let alert = UIAlertController(title: "Password Reset", message: "Password reset email sent, check your email.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .default, handler: { _ in
                        self.performSegue(withIdentifier: "unwindToSignInResetSegue", sender: self)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func CreateAlert() {
        createAlert(alertTitle: self.alertTitle, alertMessage: self.alertMessage, alertButtonText: self.alertBtnText)
    }
    
}
