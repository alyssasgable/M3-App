//
//  MesageCell.swift
//  M3
//
//  Created by Alyssa on 9/6/17.
//  Copyright © 2017 Savage. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var MessageContent: UILabel!
    
    @IBOutlet weak var Username: UILabel!
    
    @IBOutlet weak var LikeBtn: UIButton!

    
    override func awakeFromNib() {
    super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
        
    }
