//
//  GoogleSignInController.swift
//  roughpages
//
//  Created by Pranjal Chaudhari on 02/05/23.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import SwiftUI

class GoogleSignInController {
    static let googleSignInController = GoogleSignInController()
    private init() { }
    
    let iAD = InAppDetails.inAppDetails
    let db = FirebaseController.firebaseController.firestore
    @EnvironmentObject var appState: InAppDetails
    
    
}
