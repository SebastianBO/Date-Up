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
    private(set) var userProfilePicture = PictureView(id: "nil", uiImageView: UIImageView(image: UIImage(named: "blank-profile-hi")))
    public let firebaseStorageManager = FirebaseStorageManager()
    public let firestoreManager = FirestoreManager()
    @Published var session = SessionStore()
    
    init() {
        self.fetchData() {
            self.fetchPhotos {}
        }
    }
    
    init(forPreviews: Bool) {
        self.profile = Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", gender: "gender", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil)
    }
    
    func fetchData(completion: @escaping (() -> ())) {
        if (session.currentUser != nil) {
            firestoreManager.fetchDataFromDatabase(userUID: session.currentUser!.uid) { firstName, lastName, birthDate, age, country, city, language, preference, gender, bio, photosURLs, profilePictureURL in
                if photosURLs != nil {
                    self.profile = Profile(id: self.session.currentUser!.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, gender: gender, bio: bio, email: self.session.currentUser!.email!, photosURLs: photosURLs!, profilePictureURL: profilePictureURL)
                    completion()
                } else {
                    self.profile = Profile(id: self.session.currentUser!.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, gender: gender, bio: bio, email: self.session.currentUser!.email!, photosURLs: nil, profilePictureURL: nil)
                    completion()
                }
            }
        }
    }
    
    func fetchPhotos(completion: @escaping (() -> ())) {
        if (session.currentUser != nil) {
            self.downloadUserPhotos() { fetchedPictureViews in
                if fetchedPictureViews.count != 0 {
                    self.userPicturesView.removeAll()
                    
                    for fetchedPictureView in fetchedPictureViews {
                        self.userPicturesView.append(fetchedPictureView)
                    }
                    
                    if self.profile?.profilePictureURL != nil {
                        self.firebaseStorageManager.downloadImageFromStorage(userID: self.session.currentUser!.uid, userPhotoURL: (self.profile?.profilePictureURL)!) { downloadedImage in
                            self.userProfilePicture = PictureView(id: (self.profile?.profilePictureURL)!, uiImageView: downloadedImage)
                            completion()
                        }
                    } else {
                        completion()
                    }
                } else {
                    completion()
                }
            }
        }
    }
    
    func downloadUserPhotos(completion: @escaping (([PictureView]) -> ())) {
        var userImages: [PictureView] = [PictureView]()
        
        let g = DispatchGroup()
        if self.profile?.photosURLs != nil {
            for photoURLIndex in 0..<(self.profile?.photosURLs?.count)! {
                g.enter()
                self.firebaseStorageManager.downloadImageFromStorage(userID: session.currentUser!.uid, userPhotoURL: (self.profile?.photosURLs![photoURLIndex])!) { downloadedUIImageView in
                    userImages.append(PictureView(id: (self.profile?.photosURLs![photoURLIndex])!, uiImageView: downloadedUIImageView))
                    g.leave()
                }
            }
            g.notify(queue:.main) {
                completion(userImages)
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
    
    func profilePictureChange(imageID: String, newProfilePicture: PictureView, completion: @escaping (() -> ())) {
        self.firestoreManager.editProfilePictureURLInDatabase(photoURL: imageID) {
            self.profile?.profilePictureURL = imageID
            self.userProfilePicture = newProfilePicture
        }
    }
    
    func emailAddressChange(oldEmailAddress: String, password: String, newEmailAddress: String, completion: @escaping (() -> ())) {
        self.session.changeEmailAddress(oldEmailAddress: oldEmailAddress, password: password, newEmailAddress: newEmailAddress) {
            print("Successfully changed user's e-mail address")
        }
    }
    
    func passwordChange(emailAddress: String, oldPassword: String, newPassword: String, completion: @escaping (() -> ())) {
        self.session.changePassword(emailAddress: emailAddress, oldPassword: oldPassword, newPassword: newPassword) {
            print("Successfully changed user's password")
        }
    }
    
    func deleteUserImage(imageID: String, completion: @escaping (() -> ())) {
        if self.profile?.photosURLs != nil {
            let imageIndex = self.getImageIndexFromImageID(imageID: imageID)
            self.userPicturesView.remove(at: imageIndex)
            self.firebaseStorageManager.deleteImageFromStorage(userID: session.currentUser!.uid, userPhotoURL: self.profile!.photosURLs![imageIndex]) {
                print("Successfully deleted user's image")
                self.profile!.photosURLs!.remove(at: imageIndex)
                self.firestoreManager.editUserPhotosURLsInDatabase(photosURLs: self.profile!.photosURLs!) {
                    completion()
                }
            }
        }
    }
    
    func addImageURLToUserImages(imageURL: String, completion: @escaping (() -> ())) {
        if self.profile?.photosURLs != nil {
            self.profile!.photosURLs!.append(imageURL)
            self.firestoreManager.addUsersPhotoURLsToDatabase(photosURLs: (self.profile!.photosURLs!)) {
                completion()
            }
        } else {
            self.profile?.photosURLs = [String]()
            self.profile!.photosURLs!.append(imageURL)
            self.firestoreManager.addUsersPhotoURLsToDatabase(photosURLs: (self.profile!.photosURLs!)) {
                completion()
            }
        }
    }
    
    func addUploadedImageToPhotos(imageURL: String, completion: @escaping (() -> ())) {
        self.firebaseStorageManager.downloadImageFromStorage(userID: session.currentUser!.uid, userPhotoURL: imageURL) { downloadedImage in
            self.userPicturesView.append(PictureView(id: imageURL, uiImageView: downloadedImage))
            completion()
        }
    }
    
    func deleteUserData(completion: @escaping (() -> ())) {
        self.firestoreManager.deleteUserData(userUID: session.currentUser!.uid) {
            print("Successfully deleted user data")
            self.firebaseStorageManager.deleteAllImagesFromStorage(userID: self.session.currentUser!.uid, userPhotosURLs: (self.profile?.photosURLs)!) {
                print("Successfully deleted user images")
                completion()
            }
        }
    }
}

public func yearsBetweenDate(startDate: Date, endDate: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year], from: startDate, to: endDate)
    return components.year!
}



