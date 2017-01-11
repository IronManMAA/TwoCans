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
    
//    struct Request
//    {
//        var reqKey: String?
//        var name: String?
//        var title: String?
//        var status: String?
//        var role: String?
//        var text: String?
//    }
//    var requests = [Request]()    // initialize an empty Array
//    var requestsC = [Request]()    // initialize an empty Array
//    var requestsP = [Request]()    // initialize an empty Array
    

    @IBOutlet weak var tableView: UITableView!
    
    var ref: FIRDatabaseReference!
    fileprivate var refHandle: FIRDatabaseHandle!
//    var messages = Array<FIRDataSnapshot>()
    var requestsC = Array<FIRDataSnapshot>()
    var requestsP = Array<FIRDataSnapshot>()
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
                return requestsC.count
            }
            else
            {
                return requestsP.count
            }
    }
  
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0
        {
            return "Completed Requests \n "
        } else {
            return "Pending Requests"
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
            let requestSnapshot = requestsC[indexPath.row]
            let aRequest = requestSnapshot.value as! Dictionary<String, String>
//KEY            let keyreq = requestSnapshot.key
            let nameT = aRequest["name"] ?? ""
            let titleT  = aRequest["title"] ?? ""
            let roleT  = aRequest["role"] ?? ""
//KEY            cell.textLabel?.text = nameT + " (\(roleT))  + keyreq"
            cell.textLabel?.text = nameT + " (\(roleT))"
            cell.detailTextLabel?.text = "Title: " + titleT
          }
        if indexPath.section == 1
        {
            let requestSnapshot = requestsP[indexPath.row]
            let aRequest = requestSnapshot.value as! Dictionary<String, String>
            let nameT = aRequest["name"] ?? ""
            let titleT  = aRequest["title"] ?? ""
            let roleT  = aRequest["role"] ?? ""
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
            let aRequest = snapshot.value as! Dictionary<String, String>
            
//            reqKey?.key = snapshot.key
//           reqKey = snapshot.key
            
            if aRequest["status"] == "Completed" {
                self.requestsC.append(snapshot)
                //  let indexPath = IndexPath(row: self.messagesC.count-1, section: 0)
                let indexPath = IndexPath(row: self.requestsC.count-1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            } else {
                self.requestsP.append(snapshot)
                let indexPath = IndexPath(row: self.requestsP.count-1, section: 1)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        })
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if segue.identifier == "ShowDetailRequest"
        {
            let destinationVC = segue.destination as! DetailViewController
            if let selectedIndexPath = tableView.indexPathForSelectedRow
            {
                if selectedIndexPath.section==0 {
                   let aRequestSnapshot = requestsC[selectedIndexPath.row]
                   let aRequest = aRequestSnapshot.value as! Dictionary<String, String>
                   destinationVC.aRequest = aRequest
                   destinationVC.aKey = aRequestSnapshot.key
                 } else {
                   let aRequestSnapshot = requestsP[selectedIndexPath.row]
                   let aRequest = aRequestSnapshot.value as! Dictionary<String, String>
                   destinationVC.aRequest = aRequest
                   destinationVC.aKey = aRequestSnapshot.key
                }
            }
        }
        if segue.identifier == "ShowDetailNEWRequest"
        {
            let navVC = segue.destination as! UINavigationController
            // get the Navegation controller handle to request the NewRuestViewController
            // since there is only one related to that we have [0]
            let destinationVC = navVC.viewControllers[0] as! NewRequestViewController
            let nameNew = AppState.sharedInstance.displayName
            destinationVC.newRequestNameSegue = nameNew!
            var roleNew = "student"
//***** Poor Man's Role checker
            if nameNew == "Ben" {  roleNew = "teacher" } else { roleNew = "student" }
            destinationVC.roleNewSegue = roleNew
//********************
        }

    }


} // End of Class


