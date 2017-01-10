//
//  File.swift
//  TwoCans
//
//  Created by Marco Almeida on 1/7/17.
//  Copyright © 2017 The Iron Yard. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class DetailViewController: UIViewController, UITextFieldDelegate
{
    
    @IBOutlet weak var status: UISwitch?
    @IBOutlet weak var titleR: UILabel?
    @IBOutlet weak var name: UILabel?
    @IBOutlet weak var textRequest: UITextView?
    @IBOutlet weak var role: UILabel?
    @IBOutlet weak var sendButtonTapped: UIButton!
    
    var aRequest = [String: String]()

    var ref: FIRDatabaseReference!
    fileprivate var refHandle: FIRDatabaseHandle!
    var messages = Array<FIRDataSnapshot>()

    let attrs = [
        NSForegroundColorAttributeName: UIColor.orange,
        NSFontAttributeName: UIFont(name: "Georgia-Bold", size: 24)!
    ]
    
    override func viewWillAppear(_ animated: Bool){
        let request = self.aRequest
        titleR?.text = request["title"]
        name?.text = request["name"]
        textRequest?.text = request["text"]
        role?.text = request["role"]
        if (request["status"] == "Completed") {
            status?.isOn = true
        } else {
            status?.isOn = false
        }
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UINavigationBar.appearance().titleTextAttributes = attrs
        
        title = "Detail Request"
        
        configureDatabase()
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit
    {
        self.ref.child("messages").removeObserver(withHandle: refHandle)
    }

// MARK: - Firebase database methods

    func configureDatabase()
    {
        ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
        refHandle = ref.child("messages").observe(.childAdded, with: { (snapshot) -> Void in
            self.messages.append(snapshot)
//            let indexPath = IndexPath(row: self.messages.count-1, section: 0)
//            self.tableView.insertRows(at: [indexPath], with: .automatic)
//            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        })
    }
//
//    // MARK: - Action handlers
//    
//    @IBAction func signOutTapped(_ sender: UIBarButtonItem)
//    {
//        let firebaseAuth = FIRAuth.auth()
//        do
//        {
//            try firebaseAuth?.signOut()
//            AppState.sharedInstance.signedIn = false
//            AppState.sharedInstance.displayName = nil
//            print("Sign out successful")
//            performSegue(withIdentifier: "ModalLoginViewSegue", sender: self)
//            
//        } catch let signOutError as NSError
//        {
//            print("Error signing out: \(signOutError)")
//        }
//    }
//    
//    @IBAction func hideKeyboard(_ sender: UIButton)
//    {
//        if (textRequest?.isFirstResponder)!
//        {
//            textRequest?.resignFirstResponder()
//        }
//    }
//
    @IBAction func sendButtonTapped(_ sender: UIButton)
    {
        sendMessage()
    }

    func sendMessage()
    {
        if var requestText = textRequest?.text
        {
            if var username = name?.text
            {
                var titleReq = self.titleR?.text
                var statusReq = "Pending"
                if (self.status?.isOn == true) {
                    statusReq = "Completed"
                } else {
                    statusReq = "Pending"
                }
                var roleReq = self.role?.text
                
                if username == "Ben's E-mail" { roleReq = "teacher"}

// ******* poor mans' error handling
                if requestText == "" { requestText = "No request" }
                if username == "" { username = "No name" }
                if titleReq == "" || titleReq == nil  { titleReq = "No Title" }
                if statusReq == "" { statusReq = "No status" }
                if roleReq == "" || roleReq == nil  { roleReq = "No role" }
// *******

                let requestData = ["text": requestText, "name": username, "title": titleReq, "status": statusReq, "role": roleReq]
                ref.child("messages").childByAutoId().setValue(requestData)
              
            }
        }
    }
    
    
} // End of Class
