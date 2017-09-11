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
    var userUid: String!
    var username: String!

    
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
        guard let email = emailField.text, let password = passwordField.text else {
            print("Form is not valid")
            return
        }
       
            Auth.auth().signIn(withEmail: email, password: password) { (user, error)
                in
                if error == nil {
                    self.userUid = user?.uid
                    
                    KeychainWrapper.standard.set(self.userUid, forKey: "uid")
                    self.performSegue(withIdentifier: "toFeed", sender: nil)
                    
                    } else {
                    
                    self.performSegue(withIdentifier: "toSignUp", sender: nil)

    }
            }

}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSignUp" {
            if let destination = segue.destination as? ViewController {
                if self.userUid != nil {
                    destination.userUid = userUid
                }
                
                if self.emailField.text != nil {
                    
                    destination.emailField = emailField
                }
                if self.passwordField.text != nil {
                    destination.passwordField = passwordField
                }
                
            }
        }
        if segue.identifier == "toFeed" {
            if let destination = segue.destination as? Feed {
                if username != nil {
                    destination.username = username
                }

    }
    }
    }
    @IBAction func createAccount(_ sender: Any) {
        guard let email = emailField.text, let password = passwordField.text, let username = usernameField.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authenticated user
            let ref = Database.database().reference()
            let usersReference = ref.child("users").child(uid)
            let values = ["username": username, "email": email]
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                
                if let err = err {
                    print(err)
                    return
                }
                
                
                self.performSegue(withIdentifier: "toFeed", sender: nil)
            })
           
        })
    }

    @IBAction func cancel (_sender: AnyObject) {
        dismiss(animated: true, completion: nil)
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
