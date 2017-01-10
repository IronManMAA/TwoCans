//
//  LoginViewController.swift
//  TwoCans
//
//  Created by Joben Gohlke on 1/2/17.
//  Copyright © 2017 The Iron Yard. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController
{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var newUserSwitch: UISwitch!
    @IBOutlet weak var signInButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        if let user = FIRAuth.auth()?.currentUser
        {
            userIsSignedIn(user)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func processLogin(_ sender: UIButton)
    {
        if let email = emailTextField.text, let password = passwordTextField.text
        {
            if newUserSwitch.isOn
            {
                FIRAuth.auth()?.createUser(withEmail: email, password: password) {
                    user, error in
                    if let error = error
                    {
                        print(error.localizedDescription)
                        return
                    }
                    
                    print("User created successfully")
                    self.setDisplayName(user!)
                }
            }
            else
            {
                FIRAuth.auth()?.signIn(withEmail: email, password: password) {
                    user, error in
                    if let error = error
                    {
                        print(error.localizedDescription)
                        return
                    }
                    
                    print("Sign in successful")
                    self.userIsSignedIn(user!)
                }
            }
        }
    }
    
    @IBAction func userSwitchValueChanged(_ sender: UISwitch)
    {
        
    }
    
    // MARK: - Helper functions
    
    fileprivate func setDisplayName(_ user: FIRUser)
    {
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
        changeRequest.commitChanges() {
            error in
            if let error = error
            {
                print(error.localizedDescription)
                return
            }
            let currentUser = (FIRAuth.auth()?.currentUser!)!
            self.userIsSignedIn(currentUser)
        }
    }
    
    fileprivate func userIsSignedIn(_ user: FIRUser)
    {
        AppState.sharedInstance.signedIn = true
        AppState.sharedInstance.displayName = user.displayName ?? user.email
        dismiss(animated: true, completion: nil)
    }
}
