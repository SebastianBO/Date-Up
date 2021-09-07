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
    
    func uploadImageToStorage(image: UIImage, userID: String, completion: @escaping ((String) -> ())) {
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
                
                completion(imageUUID)
            }
        }
    }
    
    func deleteImageFromStorage(userID: String, userPhotoURL: String, completion: @escaping (() -> ())) {
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(userPhotoURL)")
        userImagesStorageRef.delete() { (error) in
            if let error = error {
                print("Error deleting file: ", error.localizedDescription)
            }
            
            completion()
        }
    }
    
    func deleteAllImagesFromStorage(userID: String, userPhotosURLs: [String], completion: @escaping (() -> ())) {
        for photoURL in userPhotosURLs {
            let userImagesStorageRef = storageRef.child("images/\(userID)/\(photoURL)")
            userImagesStorageRef.delete() { (error) in
                if let error = error {
                    print("Error deleting file: ", error.localizedDescription)
                }
                
                completion()
            }
        }
    }
    
    func downloadImageFromStorage(userID: String, userPhotoURL: String, completion: @escaping ((UIImageView) -> ())) {
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(userPhotoURL)")
        let downloadedImage: UIImageView = UIImageView()
        
        userImagesStorageRef.getData(maxSize: 1 * 100 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("Error downloading file: ", error.localizedDescription)
            } else {
                let image = UIImage(data: data!)!
                downloadedImage.image = image
                downloadedImage.accessibilityLabel = userPhotoURL
                completion(downloadedImage)
            }
        }
    }
}
