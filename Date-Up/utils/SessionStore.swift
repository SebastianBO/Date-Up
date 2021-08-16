//
//  SessionStore.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 09/08/2021.
//

import Foundation
import Firebase

struct User {
    var uid: String
    var email: String
}

class SessionStore: ObservableObject {
    @Published var session: User?
    @Published var isAnonymous = true
    
    var handle: AuthStateDidChangeListenerHandle?
    let authRef = Auth.auth()
    
    func listen() {
        handle = authRef.addStateDidChangeListener({ (auth, user) in
            if let user = user {
                self.isAnonymous = false
                self.session = User(uid: user.uid, email: user.email!)
            } else {
                self.isAnonymous = true
                self.session = nil
            }
        })
    }
    
    func signIn(email: String, password: String) {
        authRef.signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func signUp(firstName: String, lastName: String, birthDate: Date, email: String, password: String, preference: String) {
        authRef.createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error)
            } else {
                let db = Firestore.firestore()
                let age = yearsBetweenDate(startDate: birthDate, endDate: Date())
                let documentData: [String: Any] = [
                    "id": result!.user.uid,
                    "firstName": firstName,
                    "lastName": lastName,
                    "birthDate": birthDate,
                    "age": age,
                    "email": email,
                    "password": password,
                    "preference": preference
                ]
                db.collection("profiles").document(result!.user.uid).setData(documentData) { (error) in
                    if let error = error {
                        print(error)
                    }
                }
            }
        }
    }
    
    func signOut() -> Bool {
        do {
            self.session = nil
            self.isAnonymous = true
            try authRef.signOut()
            return true
        } catch {
            return false
        }
    }
    
    func unbind() {
        if let handle = handle {
            authRef.removeStateDidChangeListener(handle)
        }
    }
}
