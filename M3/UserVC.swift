//
//  UserVC.swift
//  M3
//
//  Created by Alyssa on 8/10/17.
//  Copyright © 2017 Savage. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper

class UserVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userImagePicker: UIImageView!
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var completeSignInBtn: UIButton!
    
    var userUid: String!
    
    var emailField: String!
    
    var passwordField: String!
    
    var imagePicker : UIImagePickerController!
    
    var imageSelected = false
    
    var username: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = true
    }
    
    func keychain(){
        
        KeychainWrapper.standard.set(userUid, forKey: "uid")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            userImagePicker.image = image
            
            imageSelected = true
            
        } else {
            
            print("image wasnt selected")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func setUpUser(img: String){
        
        let userData = [
            "username": username!,
            "userImg": img
        ]
        
       // keychain()
        
        let setLocation = Database.database().reference().child("users").child(userUid)
        
        setLocation.setValue(userData)
    }
    
    func uploadImg() {
        
        if usernameField.text == nil {
            
            print("must have username")
            
            completeSignInBtn.isEnabled = false
            
        } else {
            
            username = usernameField.text
            
            completeSignInBtn.isEnabled = true
        }
        guard let img = userImagePicker.image, imageSelected == true else {
            
            print("image must be selected")
            
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            
            let metadata = StorageMetadata()
            
            metadata.contentType = "img/jpeg"
            
            Storage.storage().reference().child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                
                if error != nil {
                    
                    print("did not upload img")
                    
                } else {
                    
                    print("uploaded")
                    
                    let downloadURl = metadata?.downloadURL()?.absoluteString
                    
                    if let url = downloadURl {
                        
                        self.setUpUser(img: url)
                    }
                }
            }
        }
    }
    
    @IBAction func completeAccount(_ sender: Any){
        
        Auth.auth().createUser(withEmail: emailField, password: passwordField, completion: { (user,error) in
            
            if error != nil {
                
                print("Can't create user \(String(describing: error))")
                
            } else {
                
                if let user = user {
                    
                    self.userUid = user.uid
                }
            }
            
            self.uploadImg()
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func seletedImagePicker(_ sender: Any){
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: AnyObject){
        
        dismiss(animated: true, completion: nil)
    }
}
