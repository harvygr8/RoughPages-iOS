//
//  GoogleSignInButton.swift
//  RoughPages
//
//  Created by Pranjal Chaudhari on 13/04/23.
//

import SwiftUI
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

struct GoogleSignInButton: View {
    @State var isActive = false
    @State private var actionState: Int? = 0
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white).shadow(radius: 5,x: 0,y: 4)
            HStack{
                Image("google_logo").resizable().frame(width: 24,height: 24)
                Text("Google").font(.custom("Poppins-Regular", size: 18)).foregroundColor(.black)
            }
        }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: 50)
//            .simultaneousGesture(TapGesture().onEnded{
//                signIn()
//                re
//            })
    }
    
    func signIn() {
      // 1
      if GIDSignIn.sharedInstance.hasPreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            authenticateUser(for: user, with: error)
        }
      } else {
        // 2
        //guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // 3
        //let configuration = GIDConfiguration(clientID: clientID)
          guard let clientID = FirebaseApp.app()?.options.clientID else {
               fatalError("No client ID found in Firebase configuration")
             }
             let config = GIDConfiguration(clientID: clientID)
             GIDSignIn.sharedInstance.configuration = config
        
        // 4
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
        // 5
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) {
            result, error in
            authenticateUser(for: result?.user, with: error)
        }
      }
    }

    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
      // 1
      if let error = error {
        print(error.localizedDescription)
        return
      }
      
      // 2
        guard let accessToken = user?.accessToken, let idToken = user?.idToken else { return }
      
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
      
      // 3
      Auth.auth().signIn(with: credential) {(_, error) in
        if let error = error {
          print(error.localizedDescription)
        } else {
          print("Google sign in success")
            isActive = true
            actionState = 1
        }
        return
      }
    }

}


struct GoogleSignInButton_Previews: PreviewProvider {
    static var previews: some View {
        GoogleSignInButton()
    }
}
