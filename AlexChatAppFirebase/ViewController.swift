//
//  ViewController.swift
//  AlexChatAppFirebase
//
//  Created by Alex Lee on 12/05/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var emailAddressAfterSuccess = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
//        let ref = Database.database().reference()
        
//        print("●●●●●● : ", ref.child("someId"))
//
//        ref.child("someId/name").setValue("Alex")
//
//        ref.childByAutoId().setValue(["name":"John", "age":25, "role":"admin"])
//        ref.child("someId").observeSingleEvent(of: .value) { (snapshot) in
//            let name = snapshot.value as? String
//            let name2 = snapshot.value as? [String:Any]
//            print("●●●●●● : ", name2)
//        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "formCell", for: indexPath) as! FormCell
        if indexPath.row == 0 {
            // Sgin in Cell
            cell.usernameContainer.isHidden = true
            cell.actionButton.setTitle("Login", for: .normal)
            cell.slideButton.setTitle("Sign Up 👉", for: .normal)
            cell.slideButton.addTarget(self, action: #selector(slideToSignUpCell(_:)), for: .touchUpInside)
            cell.actionButton.addTarget(self, action: #selector(didPressLogIn(_:)), for: .touchUpInside)
            cell.emailAddressTF.text = cell.emailAddressContent
            
        } else if indexPath.row == 1 {
            cell.usernameContainer.isHidden = false
            cell.actionButton.setTitle("Sing Up", for: .normal)
            cell.slideButton.setTitle("👈 Sign In", for: .normal)
            cell.slideButton.addTarget(self, action: #selector(slideToLoginCell(_:)), for: .touchUpInside)
            cell.actionButton.addTarget(self, action: #selector(didPressSignUp(_:)), for: .touchUpInside)
        }
        
        return cell
    }
    
    @objc func didPressLogIn(_ sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as! FormCell
        
        guard let emailAddress = cell.emailAddressTF.text, let password = cell.passwordTF.text else {
            return
        }
        if emailAddress.isEmpty || password.isEmpty {
            self.displayError(errorText: "아이디 또는 비밀번호를 입력해주세요"); return
        }
        
        Auth.auth().signIn(withEmail: emailAddress, password: password) { (result, error) in
            if error == nil {
                print("●●●●●● result: ", result)
                self.makeAlert(title: "Success", message: "로그인되었습니다")
                
                
//                self.dismiss(animated: true)
                
            } else {
                print("--------------------------[error executed]--------------------------")
                self.displayError(errorText: "아이디 또는 비밀번호가 잘못되었습니다")
                
            }
        }
    }
    
    func displayError(errorText: String) {
        let alert = UIAlertController(title: "Error", message: errorText, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .default) { _ in }
        
        alert.addAction(action1)
        present(alert, animated: true)
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "확인", style: .default) { _ in
            self.dismiss(animated: true)
        }
//        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(action1);
        present(alert, animated: true)
    }
    
    
    @objc func didPressSignUp(_ sender: UIButton) {
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as! FormCell
        
//        let loginCell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as! FormCell
//        loginCell.emailAddressTF.text = "asd"
        // [Question??] 왜 에러??
        
        guard let emailAddress = cell.emailAddressTF.text, let password = cell.passwordTF.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: emailAddress, password: password) { (result, error) in
            if error == nil {
                print("●●●●●● message: ", result?.user.uid)
                
                guard let userId = result?.user.uid, let userName = cell.userNameTF.text else { return }
                
                let reference = Database.database().reference()
                let user = reference.child("users").child(userId)
                let dataArray: [String: Any] = ["username": userName]
                user.setValue(dataArray)
                
                let typedEmailAddress = cell.emailAddressTF.text
                
                let alert = UIAlertController(title: "Success", message: "회원가입 되었습니다", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "OK", style: .default) { _ in
                    self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: [.centeredHorizontally], animated: true)
                    
                    cell.emailAddressContent = typedEmailAddress!
//                    loginCell.emailAddressTF.text = typedEmailAddress
                }
                alert.addAction(action1);
                self.present(alert, animated: true)
                
            } else {
                print("--------------------------[error executed]--------------------------")
                self.makeAlert(title: "회원가입 실패", message: "입력정보를 확인해주세요")
            }
        }
        
    }
    
    
    
    
    
    @objc func slideToSignUpCell(_ sender: UIButton) {
        let indexPath = IndexPath(row: 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
    }
    
    @objc func slideToLoginCell(_ sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("★★★★ CollectionView Frame Size: ", collectionView.frame.size)
        return collectionView.frame.size
    }
    
}
