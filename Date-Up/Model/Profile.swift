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
    var email: String
    
//    init(name: String, lastName: String, birthDate: Date, preference: String) {
//        self.id = user!.uid
//        self.name = name
//        self.lastName = lastName
//        self.birthDate = birthDate
//        self.age = yearsBetweenDate(startDate: birthDate, endDate: Date())
//        self.preference = preference
//        self.email = (user?.email!)!
//    }
    
    
}
