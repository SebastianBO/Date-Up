//
//  HomeViewModel.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 06/09/2021.
//

import Foundation
import Firebase
import FirebaseStorage
import SwiftUI
import UIKit

class HomeViewModel: ObservableObject {
    @Published var allProfiles = [ProfileLookup]()
    private var allUsersUIDs = [String]()
    
    public let firebaseStorageManager = FirebaseStorageManager()
    public let firestoreManager = FirestoreManager()
    @Published var session = SessionStore()
    
    init(forPreviews: Bool) {
        self.allProfiles = [ProfileLookup(profile: Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))]), ProfileLookup(profile: Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))])]
    }
    
    init() {
        fetchData {}
    }
    
    func fetchData(completion: @escaping (() -> ())) {
        self.allProfiles.removeAll()
        if (session.currentUser != nil) {
            getAllUserUIDsOfSamePreference() { [self] filledArray in
                self.allUsersUIDs = filledArray
                if filledArray.count != 0 {
                    for userUID in self.allUsersUIDs {
                        self.firestoreManager.fetchDataFromDatabase(userUID: userUID) { firstName, lastName, birthDate, age, country, city, language, preference, gender, bio, photosURLs, _ in
                            if photosURLs != nil {
                                self.fetchPhotos(userUID: userUID, photosURLs: photosURLs!) { fetchedPhotos in
                                    self.allProfiles.append(ProfileLookup(profile: Profile(id: userUID, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, gender: gender, bio: bio, email: self.session.currentUser!.email!, photosURLs: photosURLs!, profilePictureURL: nil), profileImageViews: fetchedPhotos))
                                    completion()
                                }
                            } else {
                                self.allProfiles.append(ProfileLookup(profile: Profile(id: userUID, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, gender: gender, bio: bio, email: self.session.currentUser!.email!, photosURLs: nil, profilePictureURL: nil), profileImageViews: [PictureView(id: "nil", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))]))
                                completion()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchPhotos(userUID: String, photosURLs: [String], completion: @escaping (([PictureView]) -> ())) {
        if (session.currentUser != nil) {
            self.downloadUserPhotos(userUID: userUID, photosURLs: photosURLs) { fetchedPictureViews in
                if fetchedPictureViews.count != 0 {
                    completion(fetchedPictureViews)
                } else {
                    completion([PictureView(id: "nil", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))])
                }
            }
        }
    }
    
    private func getAllUserUIDsOfSamePreference(completion: @escaping (([String]) -> ())) {
        var newArray = [String]()
        var loggedUserGender = ""
        var loggedUserPreference = ""
        
        firestoreManager.getRejectedUsersUIDs() { [self] rejectedUsers in
            firestoreManager.getLoggedUserGender() { fetchedGender in
                loggedUserGender = fetchedGender
                
                firestoreManager.getLoggedUserPreference() { fetchedPreference in
                    loggedUserPreference = fetchedPreference
                    
                    firestoreManager.getDatabase().collection("profiles").whereField("id", isNotEqualTo: session.currentUser!.uid).getDocuments { (querySnapshot, error) in
                        if let querySnapshot = querySnapshot {
                            for document in querySnapshot.documents {
                                let foundUserPreference = document.get("preference") as! String
                                let foundUserGender = document.get("gender") as! String
                                let foundUserUID = document.get("id") as! String
                                
                                if rejectedUsers != nil ? !rejectedUsers!.contains(foundUserUID) : true {
                                    if foundUserPreference == "Both" {
                                        if loggedUserPreference == "Both" {
                                            newArray.append(foundUserUID)
                                        } else {
                                            if loggedUserPreference == foundUserGender {
                                                newArray.append(foundUserUID)
                                            }
                                        }
                                    } else {
                                        if loggedUserPreference == "Both" {
                                            if foundUserPreference == loggedUserGender {
                                                newArray.append(foundUserUID)
                                            }
                                        } else {
                                            if foundUserPreference == loggedUserGender && loggedUserPreference == foundUserGender {
                                                newArray.append(foundUserUID)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        completion(newArray)
                    }
                }
                
            }
        }
    }
    
    func removeProfileFromProposed(userUID: String) {
        var index = 0
        for profile in self.allProfiles {
            if profile.id == userUID {
                self.firestoreManager.getRejectedUsersUIDs() { rejectedUsers in
                    var tempRejectedUsers = [String]()
                    if rejectedUsers != nil {
                        tempRejectedUsers = rejectedUsers!
                        tempRejectedUsers.append(userUID)
                    } else {
                        tempRejectedUsers = [userUID]
                    }
                    self.firestoreManager.addRejectedUsersUIDsToUsersDocumentInDatabase(rejectedUsers: tempRejectedUsers) {
                        self.allProfiles.remove(at: index)
                    }
                }
                break
            }
            index += 1
        }
        if self.allProfiles.count == 0 {
            fetchData {
                print("Fetched data so that new profiles could appear.")
            }
        }
    }
    
    func restoreAllRejectedUsers() {
        self.firestoreManager.removeAllRejectedUsersUIDsFromUsersDocumentInDatabase {
            print("Successfully restored all rejected users.")
            self.fetchData {
                print("Fetched data so that the same profiles as previously could appear.")
            }
        }
    }
    
    func downloadUserPhotos(userUID: String, photosURLs: [String], completion: @escaping (([PictureView]) -> ())) {
        var userImages: [PictureView] = [PictureView]()
        
        let g = DispatchGroup()
        if photosURLs.count != 0 {
            for photoURL in photosURLs {
                g.enter()
                self.firebaseStorageManager.downloadImageFromStorage(userID: userUID, userPhotoURL: photoURL) { downloadedUIImageView in
                    userImages.append(PictureView(id: photoURL, uiImageView: downloadedUIImageView))
                    g.leave()
                }
            }
            g.notify(queue:.main) {
                completion(userImages)
            }
        }
    }
}
