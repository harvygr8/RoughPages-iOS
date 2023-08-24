//
//  InAppDetails.swift
//  movietime
//
//  Created by Pranjal Chaudhari on 29/04/23.
//

import Foundation
import SwiftUI
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

class InAppDetails: ObservableObject{
    static let inAppDetails = InAppDetails()
    private init() { }
    
    //let db = FirebaseController.firebaseController.firestore
    //@EnvironmentObject var appState: InAppDetails
    
    var uid = ""
    var profileImage = ""
    var userName = ""
    var email = ""
    var loginStatus = ""
        
    @Published var rootViewId = UUID()
    @Published var signInComplete = false
    
//    func saveSignInDetails(result: AuthDataResult?) {
//        uid = result?.user.uid ?? ""
//        loginStatus = "loggedIn"
//        appState.rootViewId = UUID()
//    }
    
}
