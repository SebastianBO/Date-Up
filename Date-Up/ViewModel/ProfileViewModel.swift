//
//  UserViewModel.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 02/08/2021.
//

import Foundation
import Firebase

class ProfileViewModel: ObservableObject {
    @Published var profiles = [Profile]()
    private let dataBase = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    func fetchData() {
        if (user != nil) {
            dataBase.collection("profiles").whereField("id", isEqualTo: user!.uid).addSnapshotListener({(snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("no docs returned")
                    return
                }
                
                self.profiles = documents.map({documentSnapshot -> Profile in
                    let data = documentSnapshot.data()
                    let id = self.user!.uid
                    let firstName = data["firstName"] as? String ?? ""
                    let lastName = data["lastName"] as? String ?? ""
                    let birthDate = data["birthDate"] as? Date ?? Date()
                    let age = data["age"] as? Int ?? 0
                    let preference = data["preference"] as? String ?? ""
                    let email = self.user!.email
                    return Profile(id: id, firstName: firstName, lastName: lastName, birthDate: birthDate, age: age, preference: preference, email: email!)
                })
            })
        }
    }
}

public func yearsBetweenDate(startDate: Date, endDate: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year], from: startDate, to: endDate)
    return components.year!
}



