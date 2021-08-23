//
//  MessageSender.swift
//  FirebaseChattingApp
//
//  Created by Sidra Jabeen on 20/08/2021.
//

import Foundation
import  MessageKit

struct Sender: SenderType {
    
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
}

struct Media: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

extension Message: SenderType {
    var displayName: String {
        return sender.displayName
    }
    
    var senderId: String {
        return sender.senderId
    }
    
}
