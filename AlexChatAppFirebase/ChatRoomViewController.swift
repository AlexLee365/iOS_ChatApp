//
//  ChatRoomViewController.swift
//  AlexChatAppFirebase
//
//  Created by Alex Lee on 13/05/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices

class ChatRoomViewController: UIViewController {

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var stackViewTypingMessage: UIStackView! // 메세지 텍스트필드와 보내기 버튼을 포함하고 있는 컨테이너뷰 역할
    @IBOutlet weak var chatTextView: UITextView!
    
    @IBOutlet weak var downBtn: UIButton!
    
    private let imagePickerController = UIImagePickerController()
    
    var room: Room?
    
    var chatMessages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.separatorStyle = .none
        chatTableView.allowsSelection = false
        chatTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureTableview(_:))))
        
        
        downBtn.isHidden = true
        
        chatTextView.delegate = self
        chatTextView.layer.borderColor = UIColor.lightGray.cgColor
        chatTextView.layer.borderWidth = 0.3
        chatTextView.layer.cornerRadius = 6
        chatTextView.isScrollEnabled = false
        chatTextView.autocorrectionType = .no
//        chatTextView.text = "메세지를 입력해주세요"
//        chatTextView.textColor = .lightGray
        textViewDidChange(chatTextView)
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveKeyboardNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveKeyboardNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        observeMessages()
        title = room?.roomName

    }
    
    @IBAction func plusBtnDidTap(_ sender: UIButton) {  // 사진 추가 버튼
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "Camera", style: .default){ _ in
            
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            
            self.imagePickerController.sourceType = .camera
            
            self.imagePickerController.mediaTypes = [kUTTypeImage as String]
            
            self.present(self.imagePickerController, animated: true)
            
        }
        let action2 = UIAlertAction(title: "Gallery", style: .default){ _ in
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(action1); alert.addAction(action2); alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    
    @objc func tapGestureTableview(_ sender: UITapGestureRecognizer) {
//        self.view.endEditing(true)    // 편집을 끝낸다 => 키보드 내리는것과 같은 기능
        chatTextView.resignFirstResponder()
    }
    
    @IBAction func moveDownBtnDidTap(_ sender: Any) {   // 채팅 테이블뷰 맨밑으로 가는 버튼
        guard chatMessages.count > 0 else { return }
        
        self.chatTableView.scrollToRow(at: IndexPath(row: self.chatMessages.count-1, section: 0), at: UITableView.ScrollPosition.top, animated: true)

    }
    
    @objc func didReceiveKeyboardNotification(_ sender: Notification) {
        guard let userInfo = sender.userInfo
            , let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            , let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            else { return }
        
        
        let stackViewBottomConstUp = self.stackViewTypingMessage.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -keyboardFrame.height)
        let stackViewBottomConstDown = stackViewTypingMessage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        
        let keyboardHeightWithoutSafeInset = keyboardFrame.height - self.view.safeAreaInsets.bottom
        print("keyboardHeightWithoutSafeInset: ", keyboardHeightWithoutSafeInset)
        
        switch sender.name {
        case UIResponder.keyboardWillShowNotification:
            
            //                let defaultCenterYConst = floatingLabel.centerYAnchor.constraint(equalTo: wsNameTextField.centerYAnchor)
            //                defaultCenterYConst.priority = UILayoutPriority(500)
            //                defaultCenterYConst.isActive = true
            print("🔵🔵🔵 keyboardWillShow: ")
            
            
            print("Before contentOffset.y: ", self.chatTableView.contentOffset.y)
            //                guard let lastCell = self.chatTabeView.visibleCells.last,
            //                    let lastIndex = self.chatTabeView.indexPath(for: lastCell) else {return}
            UIView.animate(withDuration: duration) {
                stackViewBottomConstDown.priority = .defaultLow
                stackViewBottomConstUp.priority = .defaultHigh
                stackViewBottomConstUp.isActive = true
            }
            // 테이블뷰의 크기가 작아진 상태 (윗줄 우선순위 조정으로)
            
            self.view.layoutIfNeeded()
            
            
            if chatTableView.contentSize.height >= chatTableView.frame.height {
                self.chatTableView.contentOffset.y += keyboardHeightWithoutSafeInset
            }
            print("After contentOffset.y: ", self.chatTableView.contentOffset.y)
            
            //                self.chatTabeView.scrollToRow(at: lastIndex, at: UITableView.ScrollPosition.bottom, animated: false)
            //
            //                guard let a = lastCell as? ChatCell else {return}
            //                print("⭐️⭐️⭐️ Last Cell Text: ", a.chatTextView.text)
            
            
        case UIResponder.keyboardWillHideNotification:
            print("🔵🔵🔵 keyboardWillHide: ")
            
            //                guard let lastCell = self.chatTabeView.visibleCells.last,
            //                    let lastIndex = self.chatTabeView.indexPath(for: lastCell) else {return}
            
            print("Before contentOffset.y: ", self.chatTableView.contentOffset.y)
            
            UIView.animate(withDuration: duration) {
                stackViewBottomConstUp.priority = .defaultLow
                stackViewBottomConstDown.priority = .defaultHigh
                stackViewBottomConstDown.isActive = true
            }
            // 테이블뷰의 크기가 다시 커진 상태 (윗줄 우선순위 조정으로)
            
            if chatTableView.contentSize.height >= chatTableView.frame.height {
                self.chatTableView.contentOffset.y -= keyboardHeightWithoutSafeInset
            }
            
            self.view.layoutIfNeeded()
            print("After contentOffset.y: ", self.chatTableView.contentOffset.y)
            
            //print("After contentOffset.y: ", self.chatTabeView.contentOffset.y)
            //                self.chatTabeView.scrollToRow(at: lastIndex, at: UITableView.ScrollPosition.bottom, animated: false)
            //
            //                guard let a = lastCell as? ChatCell else {return}
            //                print("⭐️⭐️⭐️ Last Cell Text: ", a.chatTextView.text)
            
        default: break
        }
    }
    
    func observeMessages() {
        guard let roomId = self.room?.roomId else { return }
        
        let databaseRef = Database.database().reference()
        databaseRef.child("rooms").child(roomId).child("messages").observe(.childAdded) { (snapshot) in
            print("★★★★ ChatMessage Snapshot: ", snapshot)
            if let dataArray = snapshot.value as? [String: Any] {
                guard let senderName = dataArray["senderName"] as? String
                    , let messageText = dataArray["text"] as? String
                    , let userId = dataArray["senderId"] as? String
                    else { return }
                
                let message = Message.init(messageKey: snapshot.key, senderName: senderName, messageText: messageText, userId: userId)
                self.chatMessages.append(message)
                self.chatTableView.reloadData()

                self.chatTableView.scrollToRow(at: IndexPath(row: self.chatMessages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false) // row값은 0부터 시작하기때문에 count-1해줘야함
//                self.chatTabeView.contentOffset = CGPoint(x: 0, y: 0 - self.chatTabeView.contentOffset.y)
                
            }
        }
    }
    
    func getUsernameWithId(id: String, completion: @escaping (_ userName: String?) -> () ) {
        let databaseRef = Database.database().reference()
        let user = databaseRef.child("users").child(id)
        
        user.child("username").observeSingleEvent(of: .value) { (snapshot) in
             if let userName = snapshot.value as? String {
                completion(userName)
             } else {
                completion(nil)
            }
        }
    }
    
    func sendMessage(text: String, completion: @escaping (_ isSuccess: Bool) -> () ) {  // 채팅 입력 메소드 (데이터베이스 업로드)
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference()
        
        getUsernameWithId(id: userId) { (userName) in
            if let userName = userName {
                print("★★★★ userName : ", userName)
                
                if let roomdId = self.room?.roomId, let userId = Auth.auth().currentUser?.uid {
                    let dataArray: [String: Any] = ["senderName": userName, "text": text, "senderId": userId]
                    
                    // =================================== 메세지 등록 ===================================
                    let room = databaseRef.child("rooms").child(roomdId)
                    room.child("messages").childByAutoId().setValue(dataArray, withCompletionBlock: { (error, ref) in
                        if error == nil {
                            completion(true)
//                            print("Room Added to database Scucessfully")
                        } else {
                            print("--------------------------[Error executed]--------------------------")
                            completion(false)
                        }
                    })
                    
                    // =================================== 참여자 등록 ===================================
                    let participants = room.child("participants").observeSingleEvent(of: .value, with: { (snapshot) in
                        alexPrint("Succeed snapshot: \(snapshot) / snapshot Value: \(snapshot.value)")
                    })
                    room.updateChildValues(["participants" : userId])
                    room.updateChildValues(["participants" : userId], withCompletionBlock: { (error, ref) in
                        if error == nil {
                            
                            print("🔸🔸🔸 updateChildValues Succeed ")
                        } else {
                            print("--------------------------[Error executed]--------------------------")
                        }
                    })
                    
                    
                    
                    alexPrint("Failed snapshot")
                    
                }
            }
        }
    }
    
    @IBAction func sendButtonDidPress(_ sender: UIButton) {     // 채팅 보내기 버튼
        guard let chatText = chatTextView.text
            , !chatText.isEmpty, chatTextView.textColor != UIColor.lightGray else { return }
        
        sendMessage(text: chatText) { (isSuccess) in
            if isSuccess {
                self.chatTextView.text = ""
                self.textViewDidChange(self.chatTextView)
                print("message sent")
            }
        }
    }
    
    
}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatCell
        let message = chatMessages[indexPath.row]
        
        cell.setMessageData(message: message)

        if indexPath.row == 0 {
            cell.setMessageType(type: .imageType)
            let scale = 230 / UIImage(named: "testImage")!.size.width
            cell.chatImageView.image = resizeImage(image: UIImage(named: "testImage")!, scale: scale)
            print("⭐️⭐️⭐️ Imagesize : ", cell.chatImageView.image?.size)
        } else {
            cell.setMessageType(type: .textType)
            cell.chatImageView.image = nil
        }
        print(indexPath.row)
//        cell.setMessageType(type: .textType)
        
        
        if message.userId == Auth.auth().currentUser!.uid {
            cell.setBubbleType(type: .outgoing)
        } else {
            cell.setBubbleType(type: .incoming)
        }
        
        return cell
    }
    
    func resizeImage(image: UIImage, scale: CGFloat) -> UIImage? {
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let size = image.size.applying(transform)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resultImage
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let lastPageContentOffset = scrollView.contentSize.height - chatTableView.frame.height
        // lastPageCOntentOffset = 마지막 페이지의 시작 좌표 => 전체 컨텐트 높이 - 테이블뷰 프레임 높이
        
        scrollView.contentOffset.y < lastPageContentOffset - 50 ?
            (downBtn.isHidden = false) : (downBtn.isHidden = true)
        // 현재 contentOffset y좌표가 마지막페이지 보다 위로 올라갈때 다운버튼 보여지게, 그 외(마지막 페이지일때) 다운버튼 안보여지게함
        
    }
}

extension ChatRoomViewController:  UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
    
// =================================== TextView PlaceHodler 기능 ===================================
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let replaceText = (textView.text as NSString).replacingCharacters(in: range, with: text)
//        print(replaceText)
//
//        if replaceText.isEmpty {
//            textView.text = "메세지를 입력해주세요..."
//            textView.textColor = .lightGray
//
//            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
//            textView.textColor = .black
//            textView.text = text
//        }
//        else {
//            return true
//        }
//        return false
//    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
//        if self.view.window != nil {
//            if textView.textColor == UIColor.lightGray {
//                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//            }
//        }
    }
}

extension ChatRoomViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("--------------------------[ImagePicker DidfinishPickingMediaWithInfo]--------------------------")
        
        let mediaType = info[.mediaType] as! NSString
        
        if UTTypeEqual(mediaType, kUTTypeImage) {
            let originalImage = info[.originalImage] as! UIImage
            let editedImage = info[.editedImage] as? UIImage
            let selectedImage = editedImage ?? originalImage
            
            let testVC = TestViewController()
            testVC.image = selectedImage
            navigationController?.pushViewController(testVC, animated: true)
            picker.dismiss(animated: true, completion: nil)
            print("UTTYPEEqual 실행")
        }
        
    }
}
