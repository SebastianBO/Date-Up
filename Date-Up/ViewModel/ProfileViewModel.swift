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
    @Published var userPicturesView = [UIImageView]()
    public let firebaseStorageManager = FirebaseStorageManager()
    public let firestoreManager = FirestoreManager()
    @Published var session = SessionStore()
    
    init() {
        let queue = OperationQueue()
        queue.addOperation {
            self.fetchData()
        }
        queue.waitUntilAllOperationsAreFinished()
    }
    
    init(forPreviews: Bool) {
        self.profile = Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", bio: "bio", email: "email", photosURLs: ["preview"])
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
                    
                    
                    if photosURLs == nil {
                        let newPhotoURL = self.firebaseStorageManager.uploadImageToStorage(image: UIImage(named: "blank-profile-hi")!, userID: session.currentUser!.uid)
                        self.profile = Profile(id: self.session.currentUser!.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, bio: bio, email: self.session.currentUser!.email!, photosURLs: [newPhotoURL])
                        self.firestoreManager.addUsersPhotoURLsToDatabase(photosURLs: (self.profile!.photosURLs))
                    } else {
                        self.profile = Profile(id: self.session.currentUser!.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, bio: bio, email: self.session.currentUser!.email!, photosURLs: photosURLs!)
                    }
                    
                    let newUserPhotos = self.downloadUserPhotos()
                    
                    if userPicturesView.count == 0 {
                        for photoIndex in 0..<newUserPhotos.count {
                            self.userPicturesView.append(newUserPhotos[photoIndex])
                        }
                    } else {
                        for photoIndexInExisting in 0..<userPicturesView.count {
                            for photoIndexInNew in 0..<newUserPhotos.count {
                                if self.userPicturesView[photoIndexInExisting] != newUserPhotos[photoIndexInNew] {
                                    self.userPicturesView.append(newUserPhotos[photoIndexInNew])
                                }
                            }
                        }
                    }
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
    
    func addImageURLToUserImages(imageURL: String) {
        self.profile!.photosURLs.append(imageURL)
        self.firestoreManager.addUsersPhotoURLsToDatabase(photosURLs: (self.profile!.photosURLs))
    }
    
    func downloadUserPhotos() -> [UIImageView] {
        var userImages: [UIImageView] = [UIImageView]()
        
        if self.profile?.photosURLs != nil {
            for photoURLIndex in 0..<(self.profile?.photosURLs.count)! {
                userImages.append(self.firebaseStorageManager.downloadImageFromStorage(userID: session.currentUser!.uid, userPhotoURL: (self.profile?.photosURLs[photoURLIndex])!))
            }
        }
        
        return userImages
    }
}

public func yearsBetweenDate(startDate: Date, endDate: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year], from: startDate, to: endDate)
    return components.year!
}



