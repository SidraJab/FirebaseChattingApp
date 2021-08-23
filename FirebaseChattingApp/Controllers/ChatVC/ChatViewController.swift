//
//  ChatViewController.swift
//  FirebaseChattingApp
//
//  Created by Sidra Jabeen on 15/08/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase

class ChatViewController: MessagesViewController, MessagesDataSource, InputBarAccessoryViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    //MARK: - Propertities
    
    var message = [Message]()
    var myId = String()
    var chatId = String()
    var other = String()
    var myName = String()
    var otherName = String()
    var chatID:Int = 0
    var currentUser:Sender!
    var otherUser:Sender!
    var sender: Sender!
    var userID = String()
    var selectedImageFromPicker: UIImage?
    var imageURL: URL?
    
    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentUser = Sender(senderId: myId, displayName: myName)
        self.otherUser = Sender(senderId: other, displayName: otherName)
        print(userID)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        readMessage()
        addCameraBarButton()
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
      
      inputBar.inputTextView.text = ""
        guard text.count > 0 else {
            return
        }
        
        let timeStamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        print(timeStamp)
        let dic = ["senderid" : myId ,"toid" : "123" ,"message" : text , "datetime" : Date().debugDescription]
        Database.database().reference().child("chats").child(chatId).child("\(timeStamp)" ).setValue(dic)

    }

    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return message[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return message.count
    }
    
    func messageTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath
    ) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ])
    }
    
    
    // MARK: - Actions
    @objc private func cameraButtonPressed() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            picker.sourceType = .camera
//        } else {
//            picker.sourceType = .photoLibrary
//        }
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    //MARK: - Others
    
    func readMessage(){
        
        Database.database().reference().child("chats").child(chatId).observe(.value) { snapshot in
            self.message.removeAll()
            for item in snapshot.children{
                
                if let snap = item as? DataSnapshot{
                    if let dictionary = snap.value as? [String: AnyObject]
                    {
//                        let msg = message()
//                        //                        msg.toid = dictionary["toid"] as! String
                        let id = dictionary["senderid"] as! String
//                        msg.message = dictionary["message"] as! String
//                        let isoDate = dictionary["datetime"] as! String
//                        let dateFormatter = DateFormatter()
//                        let date = dateFormatter.date(from: isoDate)
//                        let sender =  Sender(senderId: dictionary["senderid"] as! String, displayName: "Sidra")
                        
                        if id == self.myId {
                            self.sender = self.currentUser
                        } else {
                            self.sender = self.otherUser
                        }
                        
                        self.message.append(Message(sender: self.sender, messageId: "1", sentDate: Date().addingTimeInterval(-56400) , kind: .text(dictionary["message"] as! String)))
                        
                    }
                }
                DispatchQueue.main.async {

                    self.messagesCollectionView.reloadData()
//                    if self.messages.count>0{
//                        let index = IndexPath(row: self.messages.count - 1, section: 0)
//                        self.tableView.scrollToRow(at: index, at: .bottom, animated: true)
//                    }
                }
            }
            
        } withCancel: { (error) in
            print(error.localizedDescription)
        }
    }
    
    func addCameraBarButton() {
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = .black
        cameraItem.image = UIImage(named: "icons8-photo-gallery-50")
        cameraItem.addTarget(
            self,
            action: #selector(cameraButtonPressed),
            for: .primaryActionTriggered)
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage") ] as? UIImage
        {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage") ] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadToFirebaseStorageUsingImage(image: UIImage) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image:", error!)
                    return
                }
                
                ref.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print(err)
                        return
                    } else {
                        print(url)
                    }
                    self.imageURL = url
                    self.sendMessageWithImageUrl(url?.absoluteString ?? "")
                })
                
            })
        }
        
    }
    
    func sendMessageWithImageUrl(_ imageUrl: String) {

        let timeStamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let values = ["senderid" : myId ,"toid" : "123" ,"message" : imageUrl , "datetime" : Date().debugDescription]
        Database.database().reference().child("chats").child(chatId).child("\(timeStamp)" ).setValue(values)

    }

}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {

  func footerViewSize(
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> CGSize {
    return CGSize(width: 0, height: 8)
  }

  func messageTopLabelHeight(
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> CGFloat {
    return 20
  }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
  func backgroundColor(
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> UIColor {
    return isFromCurrentSender(message: message) ? .gray : .green

  }

  func shouldDisplayHeader(
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> Bool {
    return false
  }

  func configureAvatarView(
    _ avatarView: AvatarView,
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) {
    avatarView.isHidden = true
  }

  func messageStyle(
    for message: MessageType,
    at indexPath: IndexPath,
    in messagesCollectionView: MessagesCollectionView
  ) -> MessageStyle {
    let corner: MessageStyle.TailCorner =
      isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
    return .bubbleTail(corner, .curved)
  }
}


class message{
    var senderid = ""
    var message = ""
    var datetime = ""
}
