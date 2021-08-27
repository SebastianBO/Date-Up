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
    @Published var userPictures = Array(repeating: UIImage(named: "blank-profile-hi")!, count: 1)
    public let firebaseStorageManager = FirebaseStorageManager()
    public let firestoreManager = FirestoreManager()
    @Published var session = SessionStore()
    
    init() {
        print("init ProfileViewModel")
        self.fetchData()
    }
    
    init(forPreviews: Bool) {
        self.profile = Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", bio: "bio", email: "email", photosURLs: nil)
    }
    
    func fetchData() {
        if (session.currentUser != nil) {
            print("Pobieram dane do ProfileViewModel z bazy")
            print(session.currentUser!.uid)
            firestoreManager.getDatabase().collection("profiles").document(session.currentUser!.uid).getDocument { (document, error) in
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
                    
                    self.profile = Profile(id: self.session.currentUser!.uid, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, country: country, city: city, language: language, preference: preference, bio: bio, email: self.session.currentUser!.email!, photosURLs: photosURLs)
                    
                    let newUserPhotos = self.downloadUserPhotos()
                    for photoIndex in 0..<newUserPhotos.count {
                        print("Tutaj wyswietle liczbe zdjec", photoIndex)
                        self.userPictures.append(newUserPhotos[photoIndex])
                    }
                    print("Tutaj wyswietle liczbe zdjec po dodaniu", self.userPictures.count)
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
        self.profile?.photosURLs?.append(imageURL)
        self.firestoreManager.addUsersPhotoURLsToDatabase(photosURLs: (self.profile?.photosURLs)!)
    }
    
    func downloadUserPhotos() -> [UIImage] {
        var userImages: [UIImage] = [UIImage]()
        
        print("2 ProfileViewModel photosURLs ---------------")
        if self.profile?.photosURLs != nil {
            let photosURLs = self.profile?.photosURLs
            for photoIndex in 0..<photosURLs!.count {
                print(photosURLs![photoIndex])
            }
        }
        print("2 ---------------")
        
        if self.profile?.photosURLs != nil {
            for photoURLIndex in 0..<(self.profile?.photosURLs!.count)! {
                userImages.append(self.firebaseStorageManager.downloadImageFromStorage(userID: session.currentUser!.uid, userPhotoURL: (self.profile?.photosURLs![photoURLIndex])!))
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



