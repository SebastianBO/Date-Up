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
    
    func uploadImageToStorage(image: UIImage, userID: String) -> String {
        let imageUUID = UUID().uuidString
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(imageUUID)")
        
        let data = image.jpegData(compressionQuality: 1)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.customMetadata = ["username": userID]
        
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
        
        return imageUUID
    }
    
    func deleteImageFromStorage(userID: String, userPhotoURL: String) {
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(userPhotoURL)")
        userImagesStorageRef.delete() { (error) in
            if let error = error {
                print("Error deleting file: ", error.localizedDescription)
            }
        }
    }
    
    func deleteAllImagesFromStorage(userID: String, userPhotosURLs: [String]) {
        for photoURL in userPhotosURLs {
            let userImagesStorageRef = storageRef.child("images/\(userID)/\(photoURL)")
            userImagesStorageRef.delete() { (error) in
                if let error = error {
                    print("Error deleting file: ", error.localizedDescription)
                }
            }
        }
    }
    
    func downloadImageFromStorage(userID: String, userPhotoURL: String) -> UIImageView {
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(userPhotoURL)")
        var downloadedImage: UIImageView = UIImageView()
        
        userImagesStorageRef.getData(maxSize: 1 * 100 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("Error downloading file: ", error.localizedDescription)
            } else {
                let image = UIImage(data: data!)!
                downloadedImage.image = image
            }
        }

        return downloadedImage
    }
}
