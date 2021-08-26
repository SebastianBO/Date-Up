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
    
    func signUpDataCreation(id: String, firstName: String, lastName: String, birthDate: Date, country: String, city: String, language: String, email: String, password: String, preference: String) {
        let age = yearsBetweenDate(startDate: birthDate, endDate: Date())
        let documentData: [String: Any] = [
            "id": id,
            "firstName": firstName,
            "lastName": lastName,
            "birthDate": birthDate,
            "age": age,
            "country": country,
            "city": city,
            "language": language,
            "email": email,
            "password": password,
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
    
    func editUserPreferenceInDatabase(preference: String) {
        let documentData: [String: Any] = [
            "preference": preference
        ]
        
        updateUserData(documentData: documentData)
    }
    
    private func updateUserData(documentData: [String: Any]) {
        let user = Auth.auth().currentUser
        
        self.db.collection("profiles").document(user!.uid).updateData(documentData) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
}
