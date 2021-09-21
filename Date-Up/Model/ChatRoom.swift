//
//  ChatRoom.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 11/09/2021.
//

import Foundation

struct ChatRoom: Equatable, Identifiable, Hashable {
    var id: String
    private(set) var users: [String]
    private(set) var profileLookups: [ProfileLookup]?
    private(set) var messages: [Message]
    private(set) var photos: [PictureView]?
    
    init(id: String, users: [String], messages: [Message]) {
        self.id = id
        self.users = users
        self.messages = messages
    }
    
    mutating func setProfileLookups(profileLookups: [ProfileLookup]) {
        self.profileLookups = profileLookups
    }
    
    mutating func setPhotos(photos: [PictureView]) {
        self.photos = photos
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        lhs.id == rhs.id
    }
}
