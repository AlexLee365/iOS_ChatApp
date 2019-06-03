//
//  ChatCell.swift
//  AlexChatAppFirebase
//
//  Created by Alex Lee on 13/05/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    
    enum bubbleType {
        case incoming
        case outgoing
    }
    enum messageType {
        case textType
        case imageType
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var chatImageView: UIImageView!
    
    @IBOutlet weak var chatStack: UIStackView!
    @IBOutlet weak var chatTextBubbleView: UIView!
    
    override func awakeFromNib() {                  // [Question??] 뭐하는메소드지 정확히???
        super.awakeFromNib()
        
        chatTextBubbleView.layer.cornerRadius = 6
        chatImageView.layer.cornerRadius = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setMessageData(message: Message) {
        userNameLabel.text = message.senderName
        chatTextView.text = message.messageText
    }
    
    func setBubbleType(type: bubbleType) {
        if type == .incoming {
            chatStack.alignment = .leading
            chatTextBubbleView.backgroundColor = #colorLiteral(red: 0.9681321979, green: 0.7788659334, blue: 0.9339367747, alpha: 0.7947078339)
            chatTextView.textColor = .black
        } else if type == .outgoing {
            chatStack.alignment = .trailing
            chatTextBubbleView.backgroundColor = #colorLiteral(red: 0.4562799335, green: 0.7269678712, blue: 0.8240340352, alpha: 0.8042326627)
            chatTextView.textColor = .white
        }
    }
    
    func setMessageType(type: messageType) {
        let chatTextViewTopConst = chatTextView.topAnchor.constraint(equalTo: chatTextBubbleView.topAnchor)
        let chatTextViewBotConst = chatTextView.bottomAnchor.constraint(equalTo: chatTextBubbleView.bottomAnchor)
        
        let chatImageViewTopConst = chatImageView.topAnchor.constraint(equalTo: chatTextBubbleView.topAnchor, constant: 5)
        let chatImageViewBotConst = chatImageView.bottomAnchor.constraint(equalTo: chatTextBubbleView.bottomAnchor, constant: -5)
        let chatImageViewHeightConst = chatImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 500)
        
        
        if type == .textType {      //  메세지가 텍스트일때
            chatTextView.isHidden = false
            chatImageView.isHidden = true
            
            chatTextViewTopConst.priority = .defaultHigh
            chatTextViewTopConst.isActive = true
            chatTextViewBotConst.priority = .defaultHigh
            chatTextViewBotConst.isActive = true
            
            chatImageViewTopConst.priority = .defaultLow
            chatImageViewBotConst.priority = .defaultLow
            chatImageViewHeightConst.isActive = false
            
        } else if type == .imageType {      // 메세지가 이미지일때
            chatTextView.isHidden = true
            chatImageView.isHidden = false
            
            chatImageViewTopConst.priority = .defaultHigh
            chatImageViewTopConst.isActive = true
            chatImageViewBotConst.priority = .defaultHigh
            chatImageViewBotConst.isActive = true
            chatImageViewHeightConst.isActive = true
            
            chatTextViewTopConst.priority = .defaultLow
            chatTextViewBotConst.priority = .defaultLow
        }
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {        // [Question??] awakeFromNib 이랑 어떻게 다르지????
        super.init(coder: aDecoder)
    }

}
