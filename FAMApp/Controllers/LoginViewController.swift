//
//  ViewController.swift
//  FAMApp
//
//  Created by Khyteang on 8/5/18.
//  Copyright © 2018 Khyteang. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    var handle: AuthStateDidChangeListenerHandle?    
    var currentUser: UserModel?
    var currentTemplate: Template?
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    @IBAction func privacyPolicyShow(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://lrc247.github.io/FAM/privacy_policy.html")!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addLineToView(view: self.txtUsername, position:.LINE_POSITION_BOTTOM, color: UIColor.darkGray, width: 0.5)
        addLineToView(view: self.txtPassword, position:.LINE_POSITION_BOTTOM, color: UIColor.darkGray, width: 0.5)
        
        self.btnSignIn.layer.cornerRadius = 10
        self.btnSignIn.clipsToBounds = true
        self.btnSignIn.center.x = self.view.center.x
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
        if (checkLoggedIn()) {
            self.performSegue(withIdentifier: "existingUserOverviewSegue", sender: "login controller")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkLoggedIn() -> Bool {
        let user = Auth.auth().currentUser
        if user != nil {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "signUpSegue", sender: sender)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: txtUsername.text!, password: txtPassword.text!) { (user, error) in
            if (error != nil) {
                let title = "Sign in Failed!"
                let message = "Please enter valid Username and Password"
                let buttonText = "Ok"
                
                self.createAlert(alertTitle: title, alertMessage: message, alertButtonText: buttonText)
            } else {
                self.performSegue(withIdentifier: "existingUserOverviewSegue", sender: sender)
            }
        }
    }
    
    @IBAction func unwindToSignIn(segue: UIStoryboardSegue) {
        self.txtPassword.text = ""
        self.txtUsername.text = ""
    }
}
