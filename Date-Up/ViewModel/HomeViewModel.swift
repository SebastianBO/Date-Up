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
    @Published var currentProfile: ProfileLookup
    private var allUsersUIDs = [String]()
    
    public let firebaseStorageManager = FirebaseStorageManager()
    public let firestoreManager = FirestoreManager()
    @Published var session = SessionStore()
    
    init(forPreviews: Bool) {
        self.currentProfile = ProfileLookup(profile: Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))])
    }
    
    init() {
        self.currentProfile = ProfileLookup(profile: Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil), profileImageViews: [PictureView(id: "1", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "2", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi"))), PictureView(id: "3", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))])
        fetchData()
    }
    
    func fetchData() {
        if (session.currentUser != nil) {
            getAllUserUIDsOfSamePreference()
            
            for userUID in allUsersUIDs {
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
                        } else {
                            self.currentProfile = ProfileLookup(profile: Profile(id: self.session.currentUser!.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, gender: gender, bio: bio, email: self.session.currentUser!.email!, photosURLs: nil, profilePictureURL: nil), profileImageViews: [PictureView]())
                        }
                    }
                    
                    self.fetchPhotos(userUID: userUID)
                    
                    self.allProfiles.append(self.currentProfile)
                }
            }
        }
    }
    
    func fetchPhotos(userUID: String) {
        if (session.currentUser != nil) {
            let newUserPhotos = self.downloadUserPhotos()
            
            if newUserPhotos.count != 0 {
                self.currentProfile.profileImageViews.removeAll()
                self.currentProfile.profileImageViews = [PictureView]()
                for (newUserPhoto, photoURL) in zip(newUserPhotos, (self.currentProfile.profile.photosURLs)!) {
                    self.currentProfile.profileImageViews.append(PictureView(id: photoURL, uiImageView: newUserPhoto))
                }
            }
        }
    }
    
    private func getAllUserUIDsOfSamePreference() {
        let loggedUserGender = firestoreManager.getLoggedUserGender()
        let loggedUserPreference = firestoreManager.getLoggedUserPreference()
        
        firestoreManager.getDatabase().collection("profiles").whereField("gender", isEqualTo: loggedUserPreference).getDocuments() { [self] (querySnapshot, error) in
            if let error = error {
                print("Error getting all users UIDs: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let foundUserPreference = document.get("preference") as! String
                    let foundUserUID = document.get("id") as! String
                    if foundUserUID != session.currentUser!.uid && (foundUserPreference == loggedUserGender || foundUserPreference == "Both") {
                        self.allUsersUIDs.append(document.get("id") as! String)
                    }
                }
            }
        }
    }
    
    func downloadUserPhotos() -> [UIImageView] {
        var userImages: [UIImageView] = [UIImageView]()
        
        if self.currentProfile.profile.photosURLs != nil {
            for photoURLIndex in 0..<(self.currentProfile.profile.photosURLs?.count)! {
                userImages.append(self.firebaseStorageManager.downloadImageFromStorage(userID: session.currentUser!.uid, userPhotoURL: (self.currentProfile.profile.photosURLs![photoURLIndex])))
            }
        }
        
        return userImages
    }
}
