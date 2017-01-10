//
//  RequestViewController.swift
//  Requests
//
//  Created by Marco Almeida on 1/2/17.
//  Copyright © 2017 The Iron Yard. All rights reserved.
//

import UIKit
import Firebase

class RequestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate
{

    @IBOutlet weak var tableView: UITableView!
    
    var ref: FIRDatabaseReference!
    fileprivate var refHandle: FIRDatabaseHandle!
    var messages = Array<FIRDataSnapshot>()
    var messagesC = Array<FIRDataSnapshot>()
    var messagesP = Array<FIRDataSnapshot>()
    let attrs = [
        NSForegroundColorAttributeName: UIColor.orange,
       NSFontAttributeName: UIFont(name: "Georgia-Bold", size: 24)!
    ]
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
        UINavigationBar.appearance().titleTextAttributes = attrs
        
        title = "Requests"
        
        configureDatabase()

    }
    
    override func viewDidAppear(_ animated: Bool)
    {

        super.viewDidAppear(animated)
        if !AppState.sharedInstance.signedIn
        {
            performSegue(withIdentifier: "ModalLoginViewSegue", sender: self)
        }
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
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
            if section == 0
            {
                return messagesC.count
            }
            else
            {
                return messagesP.count
            }
    }
  
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0
        {
            return "Pending Requests \n "
        } else {
            return "Completed Requests"
        }
    }
    
        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
            view.tintColor = UIColor.orange
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.white
        }
        
        
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)

        if indexPath.section == 0
        {
        let messageSnapshot = messagesC[indexPath.row]
        let message = messageSnapshot.value as! Dictionary<String, String>

            let nameT = message["name"] ?? ""
            //let textT = message["text"] ?? ""
            let titleT  = message["title"] ?? ""
            //let statusT = message["status"] ?? "Pending"
            let roleT  = message["role"] ?? ""
            cell.textLabel?.text = nameT + " (\(roleT))"
            cell.detailTextLabel?.text = "Title: " + titleT
          }
        if indexPath.section == 1
        {
            let messageSnapshot = messagesC[indexPath.row]
            let message = messageSnapshot.value as! Dictionary<String, String>
            
            let nameT = message["name"] ?? ""
            //let textT = message["text"] ?? ""
            let titleT  = message["title"] ?? ""
            //let statusT = message["status"] ?? "Pending"
            let roleT  = message["role"] ?? ""
            cell.textLabel?.text = nameT + " (\(roleT))"
            cell.detailTextLabel?.text = "Title: " + titleT
        }

        return cell
    }
    
    // MARK: - Firebase database methods
    
    func configureDatabase()
    {
        
        ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
        refHandle = ref.child("messages").observe(.childAdded, with: { (snapshot) -> Void in
            self.messages.append(snapshot)

            let ii = self.messages.count
            var i = 0
            while i < ii {
                if self.messages.status == "Completed" {
                   self.messagesC.append(snapshot)
                    let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)

                } else {
                    self.messagesP.append(snapshot)
                    let indexPath = IndexPath(row: self.messages.count-1, section: 1)
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
                i = i + 1
            }
        })
        
//        print(" Count is: \(self.messages.count)")
        
    }
    
    // MARK: - Action handlers
    
    @IBAction func signOutTapped(_ sender: UIBarButtonItem)
    {
        let firebaseAuth = FIRAuth.auth()
        do
        {
            try firebaseAuth?.signOut()
            AppState.sharedInstance.signedIn = false
            AppState.sharedInstance.displayName = nil
            print("Sign out successful")
            performSegue(withIdentifier: "ModalLoginViewSegue", sender: self)
            
        } catch let signOutError as NSError
        {
            print("Error signing out: \(signOutError)")
        }
    }

    @IBAction func makeNewRequest(_ sender: UIBarButtonItem)
    {
         self.performSegue(withIdentifier: "ShowDetailRequest", sender: self)
    }
    

//    @IBAction func sendButtonTapped(_ sender: UIButton)
//    {
//        sendMessage()
//    }
    
    // MARK: - Helper functions
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if segue.identifier == "ShowDetailRequest"
        {
            let destinationVC = segue.destination as! DetailViewController
            if let selectedIndexPath = tableView.indexPathForSelectedRow
            {

                let aRequestSnapshot = messages[selectedIndexPath.row]
                let aRequest = aRequestSnapshot.value as! Dictionary<String, String>
                destinationVC.aRequest = aRequest
            }
        }
        if segue.identifier == "ShowDetailNEWRequest"
        {
            let destinationVC = segue.destination as! NewRequestViewController
            let nameNew = AppState.sharedInstance.displayName
            destinationVC.newRequestNameSegue = nameNew!
            var roleNew = "student"
            if nameNew == "Ben's E-mail" {  roleNew = "teacher" } else { roleNew = "student" }
            destinationVC.roleNewSegue = roleNew
        }

    }


//    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
//        // name this function at will.
//    }

} // End of Class


