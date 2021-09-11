//
//  Message.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 09/08/2021.
//

import Foundation

struct Message: Equatable, Identifiable, Hashable {
    var id = UUID()
    private(set) var message: String
    private(set) var user: ProfileLookup
    private(set) var timeStamp = Date()
    
    init(message: String, user: ProfileLookup) {
        self.message = message
        self.user = user
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}
