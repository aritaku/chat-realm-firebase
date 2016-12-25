//
//  ViewController.swift
//  chat-firebase
//
//  Created by 有村琢磨 on 2016/12/22.
//  Copyright © 2016年 有村琢磨. All rights reserved.
//

import UIKit
import FirebaseDatabase
import JSQMessagesViewController

class ViewController: JSQMessagesViewController {

    var messages: [JSQMessage]? {
        didSet {
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
        }
    }
    
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFirebase()
        setupChatUI()
        
        self.messages = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupFirebase() {
        let rootRef = FIRDatabase.database().reference()
        rootRef.queryLimited(toLast: 100).observe( .childAdded, with: {(snapshot) in
            let snapshotValue = snapshot.value as? NSDictionary
            let text = snapshotValue?["text"] as? String
            let from = snapshotValue?["from"] as? String
            let name = snapshotValue?["name"] as? String
            let message = JSQMessage(senderId: from, displayName: name, text: text)
            self.messages?.append(message!)
            self.finishReceivingMessage()
        })
    }
    
    func setupChatUI() {
        inputToolbar!.contentView!.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        
        self.senderId = "sei"
        self.senderDisplayName = "sei"
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: #imageLiteral(resourceName: "gakki-"), diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: #imageLiteral(resourceName: "aritaku"), diameter: 64)
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleGreen())
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleGreen())
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        self.finishSendingMessage(animated: true)
        self.sendTextToDb(text: text, senderId: self.senderId, name: self.senderDisplayName)
        self.receiveAutoMessage()
    }
    
    func sendTextToDb(text: String, senderId: String, name: String) {
        let rootRef = FIRDatabase.database().reference()
        let postRef = rootRef.childByAutoId()
        let post = ["from": senderId,
                    "name": name,
                    "text": text]
        postRef.setValue(post)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return self.messages?[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingAvatar
        }
        return self.incomingAvatar
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (self.messages?.count)!
    }
    
    func receiveAutoMessage() {
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.didFinishMessageTimer(sender:)), userInfo: nil, repeats: false)
    }
    
    func didFinishMessageTimer(sender: Timer) {
        let text = "元気だして！！頑張って！！"
        self.sendTextToDb(text: text, senderId: "gakki-", name: "がっきー")
        self.finishReceivingMessage(animated: true)
    }

}

