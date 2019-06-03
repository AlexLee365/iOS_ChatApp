//
//  FormCell.swift
//  AlexChatAppFirebase
//
//  Created by Alex Lee on 12/05/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit

class FormCell: UICollectionViewCell {
    
    var userNameContent = ""
    var emailAddressContent = ""
    var passwordContent = ""
    
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var emailAddressTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    
    @IBOutlet weak var usernameContainer: UIView!
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var slideButton: UIButton!
    
    
    @IBAction func textFieldDidEndOnExit(_ sender: UITextField) {
        
        
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
////        userNameTF.text = userNameContent
////        emailAddressTF.text = emailAddressContent
////        passwordTF.text = passwordContent
//    }
}
