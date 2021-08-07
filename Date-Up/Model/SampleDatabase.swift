//
//  SampleDatabase.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import Foundation

class SampleDatabase: ObservableObject {
    static let shared = SampleDatabase()
    var users: [User] = []
    
    private init() { }
    
    func addUserToDatabase(user: User) {
        users.append(user)
    }
}
