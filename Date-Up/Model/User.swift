//
//  User.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import Foundation

class User {
    private let id = UUID()
    private var name: String
    private var lastName: String
    private var birthDate: Date
    private var age: Int
    private var preference: String?
    private var email: String
    private var password: String
    
    init(name: String, lastName: String, birthDate: Date, preference: String?, email: String, password: String) {
        self.name = name
        self.lastName = lastName
        self.birthDate = birthDate
        self.age = 0    //Ustawić różnicę między birthDate a Date()
        self.preference = preference
        self.email = email
        self.password = password
    }
}
