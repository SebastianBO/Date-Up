//
//  HomeViewModel.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 06/09/2021.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var allProfiles: [Profile]?
    @Published var currentProfile: Profile?
    
    private var profileViewModel: ProfileViewModel
    
    public let firebaseStorageManager = FirebaseStorageManager()
    public let firestoreManager = FirestoreManager()
    @Published var session = SessionStore()
    
    init(forPreviews: Bool) {
        self.currentProfile = Profile(id: "69", firstName: "firstName", lastName: "lastName", birthDate: Date(), age: 18, country: "country", city: "city", language: "language", preference: "preference", bio: "bio", email: "email", photosURLs: [], profilePictureURL: nil)
    }
    
    init(profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
        self.allProfiles = [currentProfile]
    }
    
    private func getAllUserUIDs() -> [String] {
        
    }
}
