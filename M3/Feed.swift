//
//  TableViewController.swift
//  M3
//
//  Created by Alyssa on 8/31/17.
//  Copyright © 2017 Savage. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FirebaseAuth
import FirebaseDatabase
import UserNotifications

class Feed: UITableViewController, UNUserNotificationCenterDelegate{
    
    var dbRef: DatabaseReference!
    var message = [Message]()
    var username: String!
    var newMessage:String!
    
    var users = [User]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = Database.database().reference()
        dbRef = dbRef.child("message-items")
        
        startObservingDB()
        getUserData()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
        })
        
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action:#selector(signOut))

    }
    
    func doneClicked() {
        view.endEditing(true)
    }
    
    
    
    func startObservingDB() {
        dbRef.observe(.value, with: { (snapshot:DataSnapshot) in
            
            var newMessage = [Message]()
            
            for message in snapshot.children {
                let messageObject = Message(snapshot: message as! DataSnapshot)
                newMessage.append(messageObject)
            }
            self.message = newMessage
            self.tableView.reloadData()
    })
    }

    @IBAction func addMessage(_ sender: AnyObject) {
    
        let messageAlert = UIAlertController(title: "New Message", message: "Enter your Message", preferredStyle: .alert)
        messageAlert.addTextField(configurationHandler: { (textField: UITextField) in

            textField.placeholder = "Your message"
            
        messageAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    
                }))
        })
        if username == "Evan Dean" {
        messageAlert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action: UIAlertAction) in
            
            if let messageContent = messageAlert.textFields?.first?.text {
                let messageContent = String(messageContent.characters.map {
                    $0 == "." ? ";" : $0
                })
                let message = Message(content: messageContent, addedByUser: "Evan Dean")
                self.dbRef.child(messageContent.lowercased()).setValue(message.toAnyObject())
                
                
                //Sends notification to user
                let content = UNMutableNotificationContent()
                content.title = "M3"
                content.body = messageContent
                content.badge = 1
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

            }
            
        }))
        
        self.present(messageAlert, animated: true, completion: nil)
        
        }
}

        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func getUserData() {
        if Auth.auth().currentUser?.uid == nil {
            performSegue(withIdentifier: "toSignUp", sender: nil)
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? NSDictionary {
                    self.username = dictionary["username"] as? String
                    
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                        
                    self.navigationItem.prompt = self.username    
                    })
                    
                }
            })
        }
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return message.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MessageCell
        let message = self.message[indexPath.row]
        
        let newMessage = message.content.replacingOccurrences(of: ";", with: ".")
        cell.MessageContent?.text = newMessage
        cell.Username?.text = username
        
        
        return cell
}
    
     func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .delete {
            let message = self.message[indexPath.row]
            
            message.itemRef?.removeValue()
        }
    }
    
    @objc func signOut(_ sender: AnyObject) {
        KeychainWrapper.standard.removeObject(forKey: "uid")
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %&", signOutError)
        }
        
        performSegue(withIdentifier: "toLogin", sender: nil)
    }
    
}



