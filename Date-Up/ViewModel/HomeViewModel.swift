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
    @Published var currentProfile: ProfileLookup?
    private var allUsersUIDs = [String]()
    
    public let firebaseStorageManager = FirebaseStorageManager()
    public let firestoreManager = FirestoreManager()
    @Published var session = SessionStore()
    
    init(forPreviews: Bool) {
        self.currentProfile = ProfileLookup(profile: Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))])
    }
    
    init() {
        print("CAME TO INIT")
        self.fetchData()
    }
    
    func fetchData() {
        if (session.currentUser != nil) {
            print("STARTING FETCHING")
            getAllUserUIDsOfSamePreference()
            print("DISPLAYING USERS IN FETCH: \(allUsersUIDs)")
            
            for userUID in allUsersUIDs {
                print("USER UID: \(userUID)")
                firestoreManager.getDatabase().collection("profiles").document(userUID).getDocument { (document, error) in
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
                        
                        if photosURLs != nil {
                            self.currentProfile = ProfileLookup(profile: Profile(id: self.session.currentUser!.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, gender: gender, bio: bio, email: self.session.currentUser!.email!, photosURLs: photosURLs!, profilePictureURL: nil), profileImageViews: [PictureView]())
                            print("THERE ARE PHOTOS")
                        } else {
                            self.currentProfile = ProfileLookup(profile: Profile(id: self.session.currentUser!.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, gender: gender, bio: bio, email: self.session.currentUser!.email!, photosURLs: nil, profilePictureURL: nil), profileImageViews: [PictureView]())
                            print("THERE ARE NO PHOTOS")
                        }
                    }
                    
                    self.fetchPhotos(userUID: userUID)
                    
                    self.allProfiles.append(self.currentProfile!)
                    
                }
            }
            
            if allProfiles.count != 0 {
                self.currentProfile = allProfiles[0]
                print("THERE ARE PROFILES IN ARRAY")
            } else {
                self.currentProfile = ProfileLookup(profile: Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))])
                print("THERE ARE NO PROFILES IN ARRAY")
            }
            
        }
    }
    
    func fetchPhotos(userUID: String) {
        if (session.currentUser != nil) {
            print("STARTING DOWNLOADING PHOTOS")
            let newUserPhotos = self.downloadUserPhotos()
            
            if newUserPhotos.count != 0 {
                self.currentProfile?.profileImageViews.removeAll()
                self.currentProfile?.profileImageViews = [PictureView]()
                for (newUserPhoto, photoURL) in zip(newUserPhotos, (self.currentProfile!.profile.photosURLs)!) {
                    self.currentProfile?.profileImageViews.append(PictureView(id: photoURL, uiImageView: newUserPhoto))
                }
            }
        }
    }
    
    func getAllUserUIDsOfSamePreference() {
        self.allUsersUIDs.removeAll()
        let loggedUserGender = firestoreManager.getLoggedUserGender()
        let loggedUserPreference = firestoreManager.getLoggedUserPreference()
        
        print("STARTING DOWNLOADING USERS")
        
        firestoreManager.getDatabase().collection("profiles").getDocuments { [self] (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                print("I'M HERE")
                for document in querySnapshot.documents {
                    let foundUserPreference = document.get("preference") as! String
                    let foundUserGender = document.get("gender") as! String
                    let foundUserUID = document.get("id") as! String
                    
                    if foundUserUID != session.currentUser!.uid {
                        if foundUserPreference == "Both" {
                            if loggedUserPreference == "Both" {
                                self.allUsersUIDs.append(foundUserUID)
                            } else {
                                if loggedUserPreference == foundUserGender {
                                    self.allUsersUIDs.append(foundUserUID)
                                }
                            }
                        } else {
                            if loggedUserPreference == "Both" {
                                if foundUserPreference == loggedUserGender {
                                    self.allUsersUIDs.append(foundUserUID)
                                }
                            } else {
                                if foundUserPreference == loggedUserGender && loggedUserPreference == foundUserGender {
                                    self.allUsersUIDs.append(foundUserUID)
                                }
                            }
                        }
                    }
                }
                print("DISPLAYING USERS IN getAllUsers METHOD: \(allUsersUIDs)")
            }
        }
    }
    
    func downloadUserPhotos() -> [UIImageView] {
        var userImages: [UIImageView] = [UIImageView]()
        
        if self.currentProfile?.profile.photosURLs != nil {
            for photoURLIndex in 0..<(self.currentProfile?.profile.photosURLs?.count)! {
                userImages.append(self.firebaseStorageManager.downloadImageFromStorage(userID: session.currentUser!.uid, userPhotoURL: (self.currentProfile?.profile.photosURLs![photoURLIndex])!))
            }
        }
        
        return userImages
    }
}
