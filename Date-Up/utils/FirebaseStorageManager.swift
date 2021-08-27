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
    
    func deleteImageFromStorage(userID: String) {
        
    }
    
    func downloadImageFromStorage(userID: String, userPhotoURL: String) -> UIImage {
        let userImagesStorageRef = storageRef.child("images/\(userID)/\(userPhotoURL)")
        var downloadedImage: UIImage = UIImage()
        
        print("3 FirebaseStorageManager userPhotoURL ---------------")
        print(userPhotoURL)
        print("3 ---------------")

//        userImagesStorageRef.downloadURL { (url, error) in
//            if let error = error {
//                print("Error downloading file: ", error.localizedDescription)
//            } else {
//                let data = NSData(contentsOf: url!)
//                let image = UIImage(data: data! as Data)
//                downloadedImage = image!
//            }
//        }
        
//        userImagesStorageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
//            if let error = error {
//                print("Error downloading file: ", error.localizedDescription)
//            } else {
//                downloadedImage = UIImage(data: data!)!
//            }
//        }
//
//        return downloadedImage
        
//        userImagesStorageRef.downloadURL { url, error in
//            if error != nil {
//                // Handle error
//            } else {
//                // Get the image
//                URLSession.shared.dataTask(with: url!) { data, response, error in
//                     guard let data = data, let image = UIImage(data: data) else { return }
//                    RunLoop.main.perform {
//                         downloadedImage = image
//                    }
//                }.resume()
//            }
//        }
//        
//        return downloadedImage
    }
}
