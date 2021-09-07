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
            getAllUserUIDsOfSamePreference() { [self] filledArray in
                self.allUsersUIDs = filledArray
                for userUID in self.allUsersUIDs {
                    self.firestoreManager.fetchDataFromDatabase(userUID: userUID) { firstName, lastName, birthDate, age, country, city, language, preference, gender, bio, photosURLs, _ in
                        if photosURLs != nil {
                            self.currentProfile = ProfileLookup(profile: Profile(id: self.session.currentUser!.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, gender: gender, bio: bio, email: self.session.currentUser!.email!, photosURLs: photosURLs!, profilePictureURL: nil), profileImageViews: [PictureView]())
                            print("THERE ARE PHOTOS")
                        } else {
                            self.currentProfile = ProfileLookup(profile: Profile(id: self.session.currentUser!.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, gender: gender, bio: bio, email: self.session.currentUser!.email!, photosURLs: nil, profilePictureURL: nil), profileImageViews: [PictureView]())
                            print("THERE ARE NO PHOTOS")
                        }
                        
                        self.fetchPhotos(userUID: userUID)
                        
                        self.allProfiles.append(self.currentProfile!)
                    }
                }
                
                if self.allProfiles.count != 0 {
                    self.currentProfile = allProfiles[0]
                    print("THERE ARE PROFILES IN ARRAY")
                } else {
                    self.currentProfile = ProfileLookup(profile: Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))])
                    print("THERE ARE NO PROFILES IN ARRAY")
                }
            }
        }
    }
    
    func fetchPhotos(userUID: String) {
        if (session.currentUser != nil) {
            print("STARTING DOWNLOADING PHOTOS")
            self.downloadUserPhotos() { fetchedPhotos in
                if fetchedPhotos.count != 0 {
                    self.currentProfile?.profileImageViews.removeAll()
                    for (newUserPhoto, photoURL) in zip(fetchedPhotos, (self.currentProfile!.profile.photosURLs)!) {
                        self.currentProfile?.profileImageViews.append(PictureView(id: photoURL, uiImageView: newUserPhoto))
                    }
                }
            }
        }
    }
    
    private func getAllUserUIDsOfSamePreference(completion: @escaping (([String]) -> ())) {
        var newArray = [String]()
        var loggedUserGender = ""
        var loggedUserPreference = ""
            
        firestoreManager.getLoggedUserGender() { fetchedGender in
            loggedUserGender = fetchedGender
        }
        
        firestoreManager.getLoggedUserPreference() { fetchedPreference in
            loggedUserPreference = fetchedPreference
        }
        
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
                print("DISPLAYING USERS IN getAllUsers METHOD: \(newArray)")
                completion(newArray)
            }
        }
    }
    
    func downloadUserPhotos(completion: @escaping (([UIImageView]) -> ())) {
        var userImages: [UIImageView] = [UIImageView]()
        
        let g = DispatchGroup()
        if self.currentProfile?.profile.photosURLs != nil {
            for photoURLIndex in 0..<(self.currentProfile?.profile.photosURLs?.count)! {
                g.enter()
                self.firebaseStorageManager.downloadImageFromStorage(userID: session.currentUser!.uid, userPhotoURL: (self.currentProfile?.profile.photosURLs![photoURLIndex])!) { downloadedUIImageView in
                    userImages.append(downloadedUIImageView)
                    g.leave()
                }
            }
            g.notify(queue:.main) {
                completion(userImages)
            }
        }
    }
}
