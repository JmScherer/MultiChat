//
//  ChatViewController.swift
//  SeniorDesignProject2
//
//  Created by James Scherer on 10/20/17.
//  Copyright © 2017 James Scherer. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

final class ChatViewController: JSQMessagesViewController {
    
    // MARK: Properties
    
    var messages = [JSQMessage]()
    var channelRef: DatabaseReference?
    var channel: Channel? {
        didSet {
            title = channel?.name
        }
    }
    
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    private lazy var messageRef: DatabaseReference = self.channelRef!.child("messages")
    private var newMessageRefHandle: DatabaseHandle?

    
    private lazy var userIsTypingRef: DatabaseReference = self.channelRef!.child("typingIndicator").child(self.senderId)
    private lazy var usersTypingQuery: DatabaseQuery = self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
    private var localTyping = false

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = Auth.auth().currentUser?.uid
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        observeMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        observeTyping()
        
    }
    
    // MARK: Collection view data source (and related) methods
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("You pressed Accessory Button")
    }
    
    // MARK: Firebase related methods
    
    private func observeMessages() {
        messageRef = channelRef!.child("messages")
        
        
        let messageQuery = messageRef.queryLimited(toLast: 25)
        
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot ) -> Void in
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                
                self.addMessage(withId: id, name: name, text: text)
                
                self.finishSendingMessage()
            } else {
                print("Error! Could not decode message data")
            }
            
        })
    }
    
    private func observeTyping() {
        let typingIndicatorRef = channelRef!.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    // MARK: UI and User Interaction
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let itemRef = messageRef.childByAutoId()
        let messageItem = [ "senderId": senderId!,
                            "senderName": senderDisplayName!,
                            "text": text!,
                            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        isTyping = false
        
        finishSendingMessage()
        
    }
    
    // MARK: IBAction
    
    @IBAction func voiceChatButtonPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "ShowVoiceChat", sender: self)
        
    }
    
    @IBAction func videoChatButtonPressed(_ sender: Any) {
        
        self.performSegue(withIdentifier: "ShowVideoChat", sender: self)
        
    }
    
    
    
    // MARK: UITextViewDelegate methods
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        
        isTyping = textView.text != ""
        
        print(textView.text != "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowVoiceChat" {
            let speechVc = segue.destination as! SpeechToTextViewController
            
            speechVc.senderId = self.senderId
            speechVc.channel = channel
            speechVc.channelRef = channelRef
        }
    }
    
}
