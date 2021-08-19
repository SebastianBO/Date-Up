//
//  Profile.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 10/08/2021.
//

import Foundation

struct Profile: Codable, Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var birthDate: Date
    var age: Int
    var preference: String
    var bio: String
    var email: String 
}
