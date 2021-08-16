//
//  DatabaseAssistant.swift
//  Date-Up
//
//  Created by Łukasz Janiszewski on 16/08/2021.
//

import Foundation
import Firebase

class DatabaseAssistant {
    private let dataBase = Firestore.firestore()
    private let user = Auth.auth().currentUser
}
