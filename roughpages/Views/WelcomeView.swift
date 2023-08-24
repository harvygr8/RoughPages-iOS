//
//  WelcomeView.swift
//  RoughPages
//
//  Created by Pranjal Chaudhari on 13/04/23.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import SwiftUI


struct WelcomeView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.uid, order: .reverse)]) var localData:
        FetchedResults<LocalData>
    var strings = Strings()
    let gSC = GoogleSignInController.googleSignInController
    let iAD = InAppDetails.inAppDetails
    let db = FirebaseController.firebaseController.firestore
    @EnvironmentObject var appState: InAppDetails
    var body: some View {
        ZStack{
            Image("ui_welcome").offset(y:-75)
            VStack(alignment: .leading){
                Text(strings.welcomeTitle).font(.custom("Poppins-Bold", size: 36)).padding([.leading,.top,.trailing])
                Spacer()
                VStack{
                    NavigationLink(destination: RegisterView(username: "", emailid: "", password: "")){
                        RoundedRectangleBtn(title: strings.signUp).padding(.bottom,5)
                    }
                    NavigationLink(destination: LoginView(emailid: "", password: "")){
                        HStack{
                            Text(strings.alreadyUser)
                                .foregroundColor(.black)
                            Text(strings.login).foregroundColor(Color("secondary_blue"))
                        }.font(.custom("Poppins-Regular", size: 16))
                    }
                    HStack{
                        VStack{
                            Divider()
                        }
                        Text("OR").font(.custom("Poppins-Regular", size: 10)).foregroundColor(Color("light_grey"))
                        VStack{
                            Divider()
                        }
                    }.padding(.bottom,5)
                    GoogleSignInButton().onTapGesture {
                        signIn()
                    }
                }.padding([.leading,.trailing,.bottom])
            }
        }
    }
    
    func signIn() {
      // 1
      if GIDSignIn.sharedInstance.hasPreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            self.authenticateUser(for: user, with: error)
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
            self.authenticateUser(for: result?.user, with: error)
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
      Auth.auth().signIn(with: credential) {(result, error) in
          if let error = error {
              print(error.localizedDescription)
          } else {
              print("Google sign in success")
              iAD.uid = result?.user.uid ?? ""
              iAD.email = result?.user.email ?? ""
              iAD.userName = result?.user.displayName ?? ""
              let docRef = db.collection("Users").document(iAD.uid)
              let user = [
                  "username":iAD.userName,
                  "email": iAD.email,
                  "uid":iAD.uid,
              ]
              LocalDataCoreDataClass().editData(localData: localData.first!, uid: iAD.uid, loginStatus: "loggedIn", context: managedObjectContext)
              docRef.setData(user){ error in
                  if let error = error {
                     print("Error updating document: \(error)")
                 } else {
                     print("Document successfully updated!")
                     appState.rootViewId = UUID()
                     //isActiveSignUp = true
                 }
              }
              //self.iAD.signInComplete = true
              //self.iAD.saveSignInDetails(result: result)
              
          }
          return
      }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
