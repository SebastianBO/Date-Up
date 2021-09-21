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
    
    func signUpDataCreation(id: String, firstName: String, lastName: String, birthDate: Date, country: String, city: String, language: String, email: String, preference: String, gender: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "id": id,
            "firstName": firstName,
            "lastName": lastName,
            "birthDate": birthDate,
            "age": yearsBetweenDate(startDate: birthDate, endDate: Date()) == 0 ? 18 : yearsBetweenDate(startDate: birthDate, endDate: Date()),
            "country": country,
            "city": city,
            "language": language,
            "email": email,
            "preference": preference,
            "gender": gender,
            "bio": "Hi, I'm \(firstName)!"
        ]
        self.db.collection("profiles").document(id).setData(documentData) { (error) in
            if let error = error {
                print(error)
            } else {
                completion()
            }
        }
    }
    
    func conversationDataCreation(usersUIDs: [String], messages: [String], completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "usersUIDs": usersUIDs,
            "messages": messages,
        ]
        self.db.collection("conversations").document(UUID().uuidString).setData(documentData) { (error) in
            if let error = error {
                print(error)
            } else {
                completion()
            }
        }
    }
    
    func deleteUserData(userUID: String, completion: @escaping (() -> ())) {
        self.db.collection("profiles").document(userUID).delete() { (error) in
            if let error = error {
                print("Could not delete user data: \(error)")
            } else {
                completion()
            }
        }
    }
    
    func getLoggedUserPreference(completion: @escaping ((String) -> ())) {
        var userPreference = ""
        
        self.db.collection("profiles").document(user!.uid).getDocument { (document, error) in
            if let document = document {
                userPreference = (document.get("preference") as? String)!
                completion(userPreference)
            }
        }
    }
    
    func getLoggedUserGender(completion: @escaping ((String) -> ())) {
        var userGender = ""
        
        self.db.collection("profiles").document(user!.uid).getDocument { (document, error) in
            if let document = document {
                userGender = (document.get("gender") as? String)!
                completion(userGender)
            }
        }
    }
    
    func getRejectedUsersUIDs(completion: @escaping ([String]?) -> ()) {
        self.db.collection("profiles").document(user!.uid).getDocument { (document, error) in
            if let document = document {
                let rejectedUsersUIDs = document.get("rejectedUsersUIDs") as? [String] ?? nil
                completion(rejectedUsersUIDs)
            }
        }
    }
    
    func getLikedUsersUIDs(completion: @escaping ([String]?) -> ()) {
        self.db.collection("profiles").document(user!.uid).getDocument { (document, error) in
            if let document = document {
                let likedUsersUIDs = document.get("likedUsersUIDs") as? [String] ?? nil
                completion(likedUsersUIDs)
            }
        }
    }
    
    func fetchDataFromDatabase(userUID: String, completion: @escaping ((String, String, Date, Int, String, String, String, String, String, String, [String]?, String?) -> ())) {
        self.db.collection("profiles").document(userUID).getDocument { (document, error) in
            if let document = document {
                let firstName = document.get("firstName") as? String ?? ""
                let lastName = document.get("lastName") as? String ?? ""
                let birthDate = document.get("birthDate") as? Date ?? Date()
                let age = document.get("age") as? Int ?? 0
                let country = document.get("country") as? String ?? ""
                let city = document.get("city") as? String ?? ""
                let language = document.get("language") as? String ?? ""
                let preference = document.get("preference") as? String ?? ""
                let gender = document.get("gender") as? String ?? ""
                let bio = document.get("bio") as? String ?? ""
                let photosURLs = document.get("userPhotosURLs") as? [String] ?? nil
                let profilePictureURL = document.get("profilePictureURL") as? String ?? nil
                completion(firstName, lastName, birthDate, age, country, city, language, preference, gender, bio, photosURLs, profilePictureURL)
            }
        }
    }
    
    func fetchConversationsFromDatabase(completion: @escaping (([ChatRoom]?) -> ())) {
        var chatRooms = [ChatRoom]()
        let g = DispatchGroup()
        self.db.collection("profiles").document(user!.uid).getDocument { (document, error) in
            if let document = document {
                let userConversations = document.get("userConversations") as? [String] ?? nil
                
                if userConversations != nil {
                    self.db.collection("conversations").getDocuments { [self] (querySnapshot, error) in
                        if let error = error {
                            print("Error fetching conversations from database: ", error.localizedDescription)
                        } else {
                            for document in querySnapshot!.documents {
                                g.enter()
                                if userConversations!.contains(document.documentID) {
                                    let id = document.get("id") as? String ?? ""
                                    let users = document.get("users") as? [String] ?? nil
                                    
                                    self.db.collection("conversations").document(document.documentID).collection("messages").getDocuments { (querySnapshot, error) in
                                        if let error = error {
                                            print("Error fetching messages from database: ", error.localizedDescription)
                                        } else {
                                            var messages = [Message]()
                                            for document in querySnapshot!.documents {
                                                let message = document.get("message") as? String ?? ""
                                                let timeStamp = document.get("timeStamp") as? Date ?? Date()
                                                let authorUserID = document.get("authorUserID") as? String ?? ""
                                                messages.append(Message(message: message, picture: nil, timeStamp: timeStamp, user: authorUserID))
                                            }
                                            chatRooms.append(ChatRoom(id: id, users: users!, messages: messages))
                                            g.leave()
                                        }
                                    }
                                }
                            }
                            g.notify(queue:.main) {
                                print("chatRooms count: \(chatRooms.count)")
                                completion(chatRooms)
                            }
                        }
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func editUserFirstNameInDatabase(firstName: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "firstName": firstName
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully updated user's first name URL in database.")
            completion()
        }
    }
    
    func editUserLastNameInDatabase(lastName: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "lastName": lastName
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully updated user's last name URL in database.")
            completion()
        }
    }
    
    func editUserBioInDatabase(bio: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "bio": bio
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully updated user's bio in database.")
            completion()
        }
    }
    
    func editUserCountryInDatabase(country: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "country": country
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully edited user's country in database.")
            completion()
        }
    }
    
    func editUserCityInDatabase(city: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "city": city
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully updated user's city in database.")
            completion()
        }
    }
    
    func editUserLanguageInDatabase(language: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "language": language
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully updated user's language in database.")
            completion()
        }
    }
    
    func editUserPreferenceInDatabase(preference: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "preference": preference
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully updated user's preference in database.")
            completion()
        }
    }
    
    func editUserEmailInDatabase(email: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "email": email
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully updated user's email in database.")
            completion()
        }
    }
    
    func editUserPhotosURLsInDatabase(photosURLs: [String], completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "userPhotosURLs": photosURLs
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully updated user's pictures urls in database.")
            completion()
        }
    }
    
    func editProfilePictureURLInDatabase(photoURL: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "profilePictureURL": photoURL
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully updated user's profile picture URL in database.")
            completion()
        }
    }
    
    func addUsersPhotoURLsToDatabase(photosURLs: [String], completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "userPhotosURLs": photosURLs
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully added user's photo urls in database.")
            completion()
        }
    }
    
    func addRejectedUsersUIDsToUsersDocumentInDatabase(rejectedUsers uids: [String], completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "rejectedUsersUIDs": uids
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully added rejected users uids to user's document in database.")
            completion()
        }
    }
    
    func removeAllRejectedUsersUIDsFromUsersDocumentInDatabase(completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "rejectedUsersUIDs": [String]()
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully removed all rejected users uids from user's document in database.")
            completion()
        }
    }
    
    func addUserToLikedUsersList(likedUsers uids: [String], completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "likedUsersUIDs": uids
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully added liked users uids to user's document in database.")
            completion()
        }
    }
    
    func removeAllLikedUsersUIDsFromUsersDocumentInDatabase(completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "likedUsersUIDs": [String]()
        ]
        
        updateUserData(documentData: documentData) {
            print("Successfully removed all liked users uids from user's document in database.")
            completion()
        }
    }
    
    private func updateUserData(documentData: [String: Any], completion: @escaping (() -> ())) {
        self.db.collection("profiles").document(user!.uid).updateData(documentData) { (error) in
            if let error = error {
                print("Error updating user's data: \(error.localizedDescription)")
            } else {
                completion()
            }
        }
    }
    
    func addConversationToDatabase(conversationUID: String, usersUIDs: [String], completion: @escaping (() -> ())) {
        var userConversations = [String]()
        self.db.collection("profiles").document(user!.uid).getDocument { [self] (document, error) in
            if let document = document {
                let newUserConversations = document.get("userConversations") as? [String] ?? nil
                if newUserConversations != nil {
                    userConversations = newUserConversations!
                }
                userConversations.append(conversationUID)
                
                let documentData: [String: Any] = [
                    "userConversations": userConversations
                ]
                
                self.db.collection("profiles").document(user!.uid).updateData(documentData) { (error) in
                    let documentData: [String: Any] = [
                        "id": conversationUID,
                        "users": usersUIDs
                    ]
                    
                    if let error = error {
                        print("Error updating user's conversation data: \(error.localizedDescription)")
                    } else {
                        self.db.collection("conversations").document(conversationUID).setData(documentData) { (error) in
                            if let error = error {
                                print("Error adding conversation: \(error.localizedDescription)")
                            } else {
                                completion()
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func addMessageToDatabase(conversationUID: String, message: String, completion: @escaping (() -> ())) {
        let documentData: [String: Any] = [
            "authorUserID": user!.uid,
            "message": message,
            "timeStamp": Date()
        ]
        print("FirestoreManager: \(conversationUID)")
        self.db.collection("conversations").document(conversationUID).collection("messages").addDocument(data: documentData) { (error) in
            if let error = error {
                print("Error adding message to conversation: \(error.localizedDescription)")
            } else {
                completion()
            }
        }
    }
    
}
