//
//  FirestoreManager.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 26/08/2021.
//

import Foundation
import Firebase
import SwiftUI

class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    func getDatabase() -> Firestore {
        return self.db
    }
    
    func signUpDataCreation(id: String, firstName: String, lastName: String, birthDate: Date, country: String, city: String, language: String, email: String, preference: String) {
        let documentData: [String: Any] = [
            "id": id,
            "firstName": firstName,
            "lastName": lastName,
            "birthDate": birthDate,
            "age": yearsBetweenDate(startDate: birthDate, endDate: Date()),
            "country": country,
            "city": city,
            "language": language,
            "email": email,
            "preference": preference,
            "bio": "Hi, I'm \(firstName)!"
        ]
        self.db.collection("profiles").document(id).setData(documentData) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func deleteUserData(id: String) {
        self.db.collection("profiles").document(id).delete() { (error) in
            if let error = error {
                print("Could not delete user data: \(error)")
            }
        }
    }
    
    func editUserFirstNameInDatabase(firstName: String) {
        let documentData: [String: Any] = [
            "firstName": firstName
        ]
        
        updateUserData(documentData: documentData)
    }
    
    func editUserLastNameInDatabase(lastName: String) {
        let documentData: [String: Any] = [
            "lastName": lastName
        ]
        
        updateUserData(documentData: documentData)
    }
    
    func editUserBioInDatabase(bio: String) {
        let documentData: [String: Any] = [
            "bio": bio
        ]
        
        updateUserData(documentData: documentData)
    }
    
    func editUserCountryInDatabase(country: String) {
        let documentData: [String: Any] = [
            "country": country
        ]
        
        updateUserData(documentData: documentData)
    }
    
    func editUserCityInDatabase(city: String) {
        let documentData: [String: Any] = [
            "city": city
        ]
        
        updateUserData(documentData: documentData)
    }
    
    func editUserLanguageInDatabase(language: String) {
        let documentData: [String: Any] = [
            "language": language
        ]
        
        updateUserData(documentData: documentData)
    }
    
    func editUserPreferenceInDatabase(preference: String) {
        let documentData: [String: Any] = [
            "preference": preference
        ]
        
        updateUserData(documentData: documentData)
    }
    
    func editUserEmailInDatabase(email: String) {
        let documentData: [String: Any] = [
            "email": email
        ]
        
        updateUserData(documentData: documentData)
    }
    
    func editUserPhotosURLsInDatabase(photosURLs: [String]) {
        let documentData: [String: Any] = [
            "userPhotosURLs": photosURLs
        ]
        
        updateUserData(documentData: documentData)
    }
    
    func editProfilePictureURLInDatabase(photoURL: String) {
        let documentData: [String: Any] = [
            "profilePictureURL": photoURL
        ]
        
        updateUserData(documentData: documentData)
    }
    
    private func updateUserData(documentData: [String: Any]) {
        self.db.collection("profiles").document(user!.uid).updateData(documentData) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func addUsersPhotoURLsToDatabase(photosURLs: [String]) {
        let documentData: [String: Any] = [
            "userPhotosURLs": photosURLs
        ]
        
        self.db.collection("profiles").document(user!.uid).updateData(documentData)
    }
    
}
