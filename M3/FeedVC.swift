//
//  FeedVC.swift
//  M3
//
//  Created by Alyssa on 8/30/17.
//  Copyright © 2017 Savage. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FirebaseAuth
import FirebaseDatabase

class FeedVC: UITableViewController {

    var currentUserImageUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsersData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action:#selector(signOut))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getUsersData() {
        let uid = KeychainWrapper.standard.string(forKey: "uid")!
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot)
            in
            
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                self.currentUserImageUrl = postDict["UserImg"] as! String
            }
        })
        }
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ShareSomethingCell") as? ShareSomethingCell {
                
                cell.configCell(userImgUrl: currentUserImageUrl)
                cell.shareBtn.addTarget(self, action: #selector(toCreatePost), for: .touchUpInside)
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
 
   
    
    
    @objc func signOut(_ sender: AnyObject) {
        KeychainWrapper.standard.removeObject(forKey: "uid")
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %&", signOutError)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func toCreatePost(_ sender: AnyObject) {
        performSegue(withIdentifier: "toCreatePost", sender: nil)
    }
}
