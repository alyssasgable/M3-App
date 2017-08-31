//
//  ViewController.swift
//  M3
//
//  Created by Alyssa on 8/10/17.
//  Copyright © 2017 Savage. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import SwiftKeychainWrapper

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var userImgView: UIImageView!
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!

    
    var imagePicker: UIImagePickerController!
    var selectedImage: UIImage!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            self.performSegue(withIdentifier: "toFeed", sender: nil)
        }
    }
        func setupUser(userId: String) {
        if let imageData = UIImageJPEGRepresentation(self.userImgView.image!, 0.2) {
            let imgUid = NSUUID().uuidString
            let metaData = StorageMetadata()
            
            Storage.storage().reference().child(imgUid).putData(imageData, metadata: metaData) { (metadata, error) in
            
            
              let downloadURL = metadata?.downloadURL()?.absoluteString
            
              let userData = [
                "username": self.usernameField.text!,
                "userImg": downloadURL!
                ] as [String : Any]
            
                Database.database().reference().child("users").child(userId).setValue(userData)
                self.performSegue(withIdentifier: "toFeed", sender: nil)

        }
        
            }

      
            }
    
       @IBAction func signInPressed(_ sender: Any) {
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error)
                in
                if error != nil && !(self.usernameField.text?.isEmpty)! && self.userImgView != nil {
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                        
                        self.setupUser(userId: (user?.uid)!)
                        
                        KeychainWrapper.standard.set((user?.uid)!, forKey: "uid")
                        self.performSegue(withIdentifier: "toFeed", sender: nil)
                    }
                } else {
                    if let userID = user?.uid {
                    KeychainWrapper.standard.set((userID), forKey: "uid")
                    self.performSegue(withIdentifier: "toFeed", sender: nil)
        }
    }
}
}
    
}
    @IBAction func getPhoto (_sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
}
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            userImgView.image = image
        } else {
            print("image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}
