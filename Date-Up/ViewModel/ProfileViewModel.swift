//
//  UserViewModel.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import Foundation
import Firebase
import FirebaseStorage
import SwiftUI
import UIKit

class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var userPicturesView: [PictureView] = [PictureView]()
    public let firebaseStorageManager = FirebaseStorageManager()
    public let firestoreManager = FirestoreManager()
    @Published var session = SessionStore()
    
    init() {
        self.fetchAllData()
    }
    
    init(forPreviews: Bool) {
        self.profile = Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil)
    }
    
    func fetchAllData() {
        self.fetchData()
        self.fetchPhotos()
    }
    
    func fetchData() {
        if (session.currentUser != nil) {
            firestoreManager.getDatabase().collection("profiles").document(session.currentUser!.uid).getDocument { [self] (document, error) in
                if let document = document {
                    let firstName = document.get("firstName") as? String ?? ""
                    let lastName = document.get("lastName") as? String ?? ""
                    let birthDate = document.get("birthDate") as? Date ?? Date()
                    let age = document.get("age") as? Int ?? 0
                    let country = document.get("country") as? String ?? ""
                    let city = document.get("city") as? String ?? ""
                    let language = document.get("language") as? String ?? ""
                    let preference = document.get("preference") as? String ?? ""
                    let bio = document.get("bio") as? String ?? ""
                    let photosURLs = document.get("userPhotosURLs") as? [String] ?? nil
                    let profilePictureURL = document.get("profilePictureURL") as? String ?? nil
                    
                    if photosURLs != nil {
                        self.profile = Profile(id: self.session.currentUser!.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, bio: bio, email: self.session.currentUser!.email!, photosURLs: photosURLs!, profilePictureURL: profilePictureURL)
                    } else {
                        self.profile = Profile(id: self.session.currentUser!.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, bio: bio, email: self.session.currentUser!.email!, photosURLs: nil, profilePictureURL: nil)
                    }
                }
            }
        }
    }
    
    func fetchPhotos() {
        if (session.currentUser != nil) {
            let newUserPhotos = self.downloadUserPhotos()
            
            if newUserPhotos.count == 0 {
//                self.userPicturesView = [PictureView(id: "NULL", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))]
            } else {
                self.userPicturesView.removeAll()
                self.userPicturesView = [PictureView]()
                for (newUserPhoto, photoURL) in zip(newUserPhotos, (self.profile?.photosURLs)!) {
                    self.userPicturesView.append(PictureView(id: photoURL, uiImageView: newUserPhoto))
                }
            }
        }
    }
    
    func firstNameChange(firstName: String) -> Bool {
        if profile != nil {
            if profile!.firstName != firstName && !firstName.isEmpty {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func lastNameChange(lastName: String) -> Bool {
        if profile != nil {
            if profile!.lastName != lastName && !lastName.isEmpty {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func bioChange(bio: String) -> Bool {
        if profile != nil {
            if profile!.bio != bio && !bio.isEmpty {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func countryChange(country: String) -> Bool {
        if profile != nil {
            if profile!.country != country && !country.isEmpty {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func cityChange(city: String) -> Bool {
        if profile != nil {
            if profile!.city != city && !city.isEmpty {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func languageChange(language: String) -> Bool {
        if profile != nil {
            if profile!.language != language && !language.isEmpty {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func preferenceChange(preference: String) -> Bool {
        if profile != nil {
            if profile!.preference != preference && !preference.isEmpty {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func getImageIndexFromImageID(imageID: String) -> Int {
        if self.profile?.photosURLs != nil {
            var imageIndex = 0
            for photoURL in (self.profile?.photosURLs)! {
                if photoURL == imageID {
                    return imageIndex
                } else {
                    imageIndex += 1
                }
            }
        }
        return 0
    }
    
    func getProfilePictureIndex() -> Int {
        if self.profile?.photosURLs != nil {
            var imageIndex = 0
            for photoURL in (self.profile?.photosURLs)! {
                if photoURL == self.profile?.profilePictureURL {
                    return imageIndex
                } else {
                    imageIndex += 1
                }
            }
        }
        return 0
    }
    
    func profilePictureChange(imageID: String) {
        self.firestoreManager.editProfilePictureURLInDatabase(photoURL: imageID)
        self.profile?.profilePictureURL = imageID
    }
    
    func emailAddressChange(oldEmailAddress: String, password: String, newEmailAddress: String) {
        self.session.changeEmailAddress(oldEmailAddress: oldEmailAddress, password: password, newEmailAddress: newEmailAddress)
    }
    
    func passwordChange(emailAddress: String, oldPassword: String, newPassword: String) {
        self.session.changePassword(emailAddress: emailAddress, oldPassword: oldPassword, newPassword: newPassword)
    }
    
    func deleteUserImage(imageID: String) {
        if self.profile?.photosURLs != nil {
            let imageIndex = self.getImageIndexFromImageID(imageID: imageID)
            self.userPicturesView.remove(at: imageIndex)
            self.firebaseStorageManager.deleteImageFromStorage(userID: session.currentUser!.uid, userPhotoURL: self.profile!.photosURLs![imageIndex])
            self.profile!.photosURLs!.remove(at: imageIndex)
            self.firestoreManager.editUserPhotosURLsInDatabase(photosURLs: self.profile!.photosURLs!)
        }
    }
    
    func addImageURLToUserImages(imageURL: String) {
        if self.profile?.photosURLs != nil {
            self.profile!.photosURLs!.append(imageURL)
            self.firestoreManager.addUsersPhotoURLsToDatabase(photosURLs: (self.profile!.photosURLs!))
        } else {
            self.profile?.photosURLs = [String]()
            self.profile!.photosURLs!.append(imageURL)
            self.firestoreManager.addUsersPhotoURLsToDatabase(photosURLs: (self.profile!.photosURLs!))
        }
    }
    
    func downloadUserPhotos() -> [UIImageView] {
        var userImages: [UIImageView] = [UIImageView]()
        
        if self.profile?.photosURLs != nil {
            for photoURLIndex in 0..<(self.profile?.photosURLs?.count)! {
                userImages.append(self.firebaseStorageManager.downloadImageFromStorage(userID: session.currentUser!.uid, userPhotoURL: (self.profile?.photosURLs![photoURLIndex])!))
            }
        }
        
        return userImages
    }
    
    func deleteUserData() {
        self.firestoreManager.deleteUserData(id: session.currentUser!.uid)
        self.firebaseStorageManager.deleteAllImagesFromStorage(userID: session.currentUser!.uid, userPhotosURLs: (self.profile?.photosURLs)!)
    }
}

public func yearsBetweenDate(startDate: Date, endDate: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year], from: startDate, to: endDate)
    return components.year!
}



