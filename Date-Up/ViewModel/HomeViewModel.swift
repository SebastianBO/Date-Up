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
    @Published var currentProfile = ProfileLookup(profile: Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))])
    private var allUsersUIDs = [String]()
    
    public let firebaseStorageManager = FirebaseStorageManager()
    public let firestoreManager = FirestoreManager()
    @Published var session = SessionStore()
    
    init(forPreviews: Bool) {
        self.currentProfile = ProfileLookup(profile: Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))])
    }
    
    init() {
        fetchData {}
    }
    
    func fetchData(completion: @escaping (() -> ())) {
        if (session.currentUser != nil) {
            getAllUserUIDsOfSamePreference() { [self] filledArray in
                self.allUsersUIDs = filledArray
                if filledArray.count != 0 {
                    for userUID in self.allUsersUIDs {
                        self.firestoreManager.fetchDataFromDatabase(userUID: userUID) { firstName, lastName, birthDate, age, country, city, language, preference, gender, bio, photosURLs, _ in
                            if photosURLs != nil {
                                self.currentProfile = ProfileLookup(profile: Profile(id: self.session.currentUser!.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, gender: gender, bio: bio, email: self.session.currentUser!.email!, photosURLs: photosURLs!, profilePictureURL: nil), profileImageViews: [PictureView]())
                                self.fetchPhotos(userUID: userUID) {
                                    self.allProfiles.append(self.currentProfile)
                                    self.currentProfile = allProfiles[0]
                                    completion()
                                }
                            } else {
                                self.currentProfile = ProfileLookup(profile: Profile(id: self.session.currentUser!.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, gender: gender, bio: bio, email: self.session.currentUser!.email!, photosURLs: nil, profilePictureURL: nil), profileImageViews: [PictureView]())
                                completion()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchPhotos(userUID: String, completion: @escaping (() -> ())) {
        if (session.currentUser != nil) {
            self.downloadUserPhotos(userUID: userUID) { fetchedPictureViews in
                if fetchedPictureViews.count != 0 {
                    self.currentProfile.profileImageViews.removeAll()
                    for fetchedPictureView in fetchedPictureViews {
                        self.currentProfile.profileImageViews.append(fetchedPictureView)
                    }
                    completion()
                } else {
                    self.currentProfile.profileImageViews = [PictureView(id: "nil", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))]
                    completion()
                }
            }
        }
    }
    
    private func getAllUserUIDsOfSamePreference(completion: @escaping (([String]) -> ())) {
        var newArray = [String]()
        var loggedUserGender = ""
        var loggedUserPreference = ""
            
        firestoreManager.getLoggedUserGender() { [self] fetchedGender in
            loggedUserGender = fetchedGender
            
            firestoreManager.getLoggedUserPreference() { fetchedPreference in
                loggedUserPreference = fetchedPreference
                
                firestoreManager.getDatabase().collection("profiles").getDocuments { [self] (querySnapshot, error) in
                    if let querySnapshot = querySnapshot {
                        for document in querySnapshot.documents {
                            let foundUserPreference = document.get("preference") as! String
                            let foundUserGender = document.get("gender") as! String
                            let foundUserUID = document.get("id") as! String
                            
                            if foundUserUID != session.currentUser!.uid {
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
    
    func downloadUserPhotos(userUID: String, completion: @escaping (([PictureView]) -> ())) {
        var userImages: [PictureView] = [PictureView]()
        
        let g = DispatchGroup()
        if self.currentProfile.profile.photosURLs != nil {
            for photoURLIndex in 0..<(self.currentProfile.profile.photosURLs?.count)! {
                g.enter()
                self.firebaseStorageManager.downloadImageFromStorage(userID: userUID, userPhotoURL: (self.currentProfile.profile.photosURLs![photoURLIndex])) { downloadedUIImageView in
                    userImages.append(PictureView(id: (self.currentProfile.profile.photosURLs![photoURLIndex]), uiImageView: downloadedUIImageView))
                    g.leave()
                }
            }
            g.notify(queue:.main) {
                completion(userImages)
            }
        }
    }
}
