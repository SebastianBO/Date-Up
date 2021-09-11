//
//  ChatRoom.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 11/09/2021.
//

import Foundation

struct ChatRoom: Equatable, Identifiable, Hashable {
    var id = UUID()
    private(set) var users: [ProfileLookup]
    private(set) var messages: [Message]
    private(set) var photos: [PictureView]?
    
    init(users: [ProfileLookup], messages: [Message], photos: [PictureView]?) {
        self.users = users
        self.messages = messages
        self.photos = photos
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        lhs.id == rhs.id
    }
}
