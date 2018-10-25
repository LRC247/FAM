//
//  SignUpViewController.swift
//  FAMApp
//
//  Created by Khyteang on 9/2/18.
//  Copyright © 2018 Khyteang. All rights reserved.
//

import Firebase

class SignUpViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    var db: Firestore?
    var currentUser: User!
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnSignUp: UIButton!
    
    let MIN_PASSWORD_LENGTH: Int = 5
    let alertTitle = "Failed to sign up"
    var alertMessage = ""
    let alertBtnText = "Ok"
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))

        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.db = Firestore.firestore()
        
        addLineToView(view: self.txtUsername, position:.LINE_POSITION_BOTTOM, color: UIColor.darkGray, width: 0.5)
        addLineToView(view: self.txtName, position:.LINE_POSITION_BOTTOM, color: UIColor.darkGray, width: 0.5)
        addLineToView(view: self.txtPassword, position:.LINE_POSITION_BOTTOM, color: UIColor.darkGray, width: 0.5)
        addLineToView(view: self.txtConfirmPassword, position:.LINE_POSITION_BOTTOM, color: UIColor.darkGray, width: 0.5)
        
//        self.btnSignUp.layer.cornerRadius = 10
//        self.btnSignUp.clipsToBounds = true
//        self.btnSignUp.center.x = self.view.center.x
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        let name:NSString = txtName.text! as NSString
        let username:NSString = txtUsername.text! as NSString
        let password:NSString = txtPassword.text! as NSString
        let confirmPassword:NSString = txtConfirmPassword.text! as NSString
        
        if (username.isEqual(to: "") || name.isEqual(to: "") || password.isEqual(to: "")) {
            self.alertMessage = "Please enter the required fields"
            CreateAlert()
            
        }
        else if (password.length <= MIN_PASSWORD_LENGTH) {
            self.alertMessage = "Password must be at least 6 characters"
            CreateAlert()
            
        }
        else if (!password.isEqual(to: confirmPassword as String)) {
            self.alertMessage = "Password doesn't match"
            CreateAlert()
            
        }
        else {
            Auth.auth().createUser(withEmail: username as String, password: confirmPassword as String) { (result, error) in
                if (error != nil) {
                    self.alertMessage = "Failed to sign up"
                    self.CreateAlert()
                } else {
                    let currentUser = UserModel.init(name: result!.user.email!, uid: result!.user.uid)
                    UserModel.save(currentUser)(db: self.db!, onSuccess: { (_user: UserModel) in
                        self.performSegue(withIdentifier: "signUpUserOverviewSegue", sender: sender)
                    }, onFailure: { (error: Error?) in
                        // Alert that there was an error creating the new user model
                    })
                }
            }
        }
    }
    
    func CreateAlert() {
        createAlert(alertTitle: self.alertTitle, alertMessage: self.alertMessage, alertButtonText: self.alertBtnText)
    }
}
