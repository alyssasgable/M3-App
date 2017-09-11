//
//  Messages.swift
//  M3
//
//  Created by Alyssa on 9/1/17.
//  Copyright © 2017 Savage. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase
import FirebaseAuth


struct Message {
    let key:String!
    let content: String!
    let addedByUser: String!
    let itemRef:DatabaseReference?
    
    init (content:String, addedByUser:String, key:String = "") {
        self.key = key
        self.content = content
        self.addedByUser = addedByUser
        self.itemRef = nil
        
    }
    
    
    init (snapshot:DataSnapshot) {
        key = snapshot.key
        itemRef = snapshot.ref
        
        let contentValue = snapshot.value as? NSDictionary
        if let messageContent = contentValue!["content"] as? String {
            content = messageContent
            
        } else {
            content = ""
        }
         let userValue = snapshot.value as? NSDictionary
        if let messageUser = userValue!["addedByUser"] as? String {
            addedByUser = messageUser
        } else {
            addedByUser = ""
        }
    }
    
    
    func toAnyObject() -> Any {
        return ["content":content, "addedByUser":addedByUser]
    }
}

