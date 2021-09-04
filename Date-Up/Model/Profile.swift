//
//  Profile.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 10/08/2021.
//

import Foundation
import SwiftUI

struct Profile: Codable, Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var birthDate: Date
    var age: Int
    var country: String
    var city: String
    var language: String
    var preference: String
    var bio: String
    var email: String
    var photosURLs: [String]?
    var profilePictureURL: String?
}
