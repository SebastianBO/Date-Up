//
//  FirebaseStorageManager.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 26/08/2021.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseStorage

class FirebaseStorageManager: ObservableObject {
    private let storageRef = Storage.storage().reference()
    
    func uploadImageToStorage(image: UIImage, userID: String) {
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(UUID().uuidString)")
        
        let data = image.jpegData(compressionQuality: 0.5)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let data = data {
            userImagesStorageRef.putData(data, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error while uploading file: ", error.localizedDescription)
                }

                if let metadata = metadata {
                    print("Metadata: ", metadata)
                }
            }
        }
    }
    
    func deleteImageFromStorage(userID: String) {
        
    }
    
    func downloadImageFromStorage(userID: String) -> UIImage {
        return UIImage()
    }
}
