//
//  RoomsViewController.swift
//  AlexChatAppFirebase
//
//  Created by Alex Lee on 12/05/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit
import Firebase

class RoomsViewController: UIViewController {
    
    

    @IBOutlet weak var roomsTableView: UITableView!
    @IBOutlet weak var newRoomTF: UITextField!
    var rooms = [Room]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomsTableView.delegate = self
        roomsTableView.dataSource = self
//        roomsTableView.allowsSelection = false
        
        newRoomTF.autocorrectionType = .no
        
        observeRooms()
        observeMessages()
    }
    
  
    
    
    func observeRooms() {
        
        let databaseRef = Database.database().reference()
        
        databaseRef.child("rooms").observe(.childAdded) { (snapshot) in
//            print("●●●●●● snapshot : ", snapshot)
            if let dataArray = snapshot.value as? [String: Any] {
//                print("★★★★ : ", dataArray["roomName"])
                if let roomName = dataArray["roomName"] as? String {
                    let room = Room.init(roomId: snapshot.key, roomName: roomName)
                    self.rooms.append(room)
                    self.roomsTableView.reloadData()
                }
            }
        }
        
    }
    
    
    
    func observeMessages() {
        
        let databaseRef = Database.database().reference()
        
        
        
        databaseRef.child("rooms").observe(.childAdded) { (snapshot) in
//            print("⭐️⭐️ \(#file)-\(#function)-\(#line) [observeMessage snapshot]: ", snapshot)
            alexPrint(snapshot, header: "observeMessage snapshot")
            if let dataArray = snapshot.value as? [String: Any] {
//                print("⭐️⭐️ \(#file)-\(#function)-\(#line) [snapshot Value]: ", dataArray)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if Auth.auth().currentUser == nil { //
            presentLoginScreen()
        }
    }
    
    @IBAction func didPressLogout(_ sender: UIBarButtonItem) {
        try! Auth.auth().signOut()      // ??
        
        presentLoginScreen()
    }
    
    func presentLoginScreen() {
        let formScreen = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreen") as! ViewController
        present(formScreen, animated: true)
    }
    
    @IBAction func didPressCreateNewRoom(_ sender: Any) {
        guard let roomName = newRoomTF.text, !(roomName.isEmpty) else {
            makeAlert(title: "Message", message: "채팅방 이름을 입력해주세요")
            return
        }
        
        let databaseRef = Database.database().reference()
        let room = databaseRef.child("rooms").childByAutoId()

        let dataArray: [String: Any] = ["roomName": roomName]
        room.setValue(dataArray) { (error, ref) in
            if error == nil {
                self.newRoomTF.text = ""
                
            } else {
                print("--------------------------[Error executed]--------------------------")
            }
        }
        
    }
    
    @IBAction func newRoomTFDidEndOnExit(_ sender: Any) {
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .default) { _ in }
//        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(action1);
        present(alert, animated: true)
    }
    
    
}


extension RoomsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = rooms[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell")!
        cell.textLabel?.text = room.roomName
        cell.selectionStyle = .none
        
        let countLabel = UILabel()
        countLabel.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        countLabel.text = "0"
        countLabel.textColor = .white
        countLabel.textAlignment = .center
        countLabel.font = UIFont.systemFont(ofSize: 13)
        countLabel.backgroundColor = #colorLiteral(red: 1, green: 0.1702595949, blue: 0.07500933856, alpha: 1)
        countLabel.layer.cornerRadius = countLabel.frame.width/2
        countLabel.layer.masksToBounds = true
        
        cell.accessoryView = countLabel
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoomVC = self.storyboard?.instantiateViewController(withIdentifier: "chatRoom") as! ChatRoomViewController
        chatRoomVC.room = rooms[indexPath.row]
        
        self.navigationController?.pushViewController(chatRoomVC, animated: true)
        
    }
    
    
}
