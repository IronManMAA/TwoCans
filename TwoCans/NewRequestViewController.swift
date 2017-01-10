//
//  NewRequestViewController.swift
//  TwoCans
//
//  Created by Marco Almeida on 1/7/17.
//  Copyright © 2017 The Iron Yard. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NewRequestViewController: UIViewController, UITextFieldDelegate
{
    
    @IBOutlet weak var status: UISwitch?
    @IBOutlet weak var titleR: UITextField?
    @IBOutlet weak var name: UILabel?
    @IBOutlet weak var textRequest: UITextView?
    @IBOutlet weak var role: UILabel?
    @IBOutlet weak var sendButtonTapped: UIButton!
    //    @IBOutlet weak var requestTextFieldBottomConstraint: NSLayoutConstraint!
    
    
    var aRequest = [String: String]()
    var newRequestNameSegue = String()
    var roleNewSegue = String()

    override func viewWillAppear(_ animated: Bool){
        name?.text = self.newRequestNameSegue
        role?.text = self.roleNewSegue
        self.status?.isOn = false
    }
    
    var ref: FIRDatabaseReference!
    fileprivate var refHandle: FIRDatabaseHandle!
    var messages = Array<FIRDataSnapshot>()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "New Request"
        
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

    
    func configureDatabase()
    {
        ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
        refHandle = ref.child("messages").observe(.childAdded, with: { (snapshot) -> Void in
        self.messages.append(snapshot)
        })
    }


    @IBAction func sendButtonTapped(_ sender: UIButton)
    {
        sendMessage()
        dismiss(animated: true, completion: nil)
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
                //print(requestData)
                ref.child("messages").childByAutoId().setValue(requestData)
            }
        }
    }
    
    
    
} // End of Class
