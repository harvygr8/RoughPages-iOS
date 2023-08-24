//
//  FirebaseController.swift
//  movietime
//
//  Created by Harvinder Laliya on 27/04/23.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
// ...
      

class FirebaseController: ObservableObject {
    static let firebaseController = FirebaseController()
    private init() {
        //FirebaseApp.configure()
    }
    
    let auth = Auth.auth()
    let firestore = Firestore.firestore()
    let storage = Storage.storage()
}
