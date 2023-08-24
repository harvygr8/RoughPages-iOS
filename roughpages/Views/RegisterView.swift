//
//  RegisterView.swift
//  movietime
//
//  Created by Harvinder Laliya on 27/04/23.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

struct RegisterView: View {
    let strings = Strings()
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.uid, order: .reverse)]) var localData:
        FetchedResults<LocalData>
    @EnvironmentObject var appState: InAppDetails
    @State private var isActiveSignUp = false
    @State private var isActiveGoogle = false
    @State private var state: Int? = 0
    let auth = FirebaseController.firebaseController.auth
    let db = FirebaseController.firebaseController.firestore
    let iAD = InAppDetails.inAppDetails
    let gSC = GoogleSignInController.googleSignInController
    @State var username : String
    @State var emailid : String
    @State var password : String
    var body: some View {
        VStack{
            Text(strings.registerTitle).font(.custom("Poppins-Medium", size: 24)).frame(minWidth: 0,maxWidth: .infinity,alignment: .leading)
            TextField(strings.username, text:$username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .border(Color(UIColor.separator))
                .cornerRadius(2)
                .padding(.top,6)
            TextField(strings.email,text: $emailid)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .border(Color(UIColor.separator))
                .cornerRadius(2)
                .padding(.top,12)
            SecureField(strings.password,text: $password)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .border(Color(UIColor.separator))
                .cornerRadius(2)
                .padding(.top,12)
            Spacer()
            RoundedRectangleBtn(title: strings.signUp).padding(.bottom,5).onTapGesture {
                auth.createUser(withEmail: emailid, password: password){(result,error) in
                    if let error = error as NSError? {
                        guard let errorCode = AuthErrorCode.Code(rawValue: error.code) else {
                            print("there was an error logging in but it could not be matched with a firebase code")
                            return
                        }
                        print("Failed to create user due to error: ",errorCode.rawValue)
                        return
                    }
                    iAD.uid = result?.user.uid ?? ""
                    iAD.email = emailid
                    iAD.userName = username
                    print("Successfully created user with account ID: ",iAD.uid)
                    
                    if localData.isEmpty || localData.first == nil {
                        LocalDataCoreDataClass().addData(uid: iAD.uid,loginStatus: "loggedIn", context: managedObjectContext)
                    }else{
                        LocalDataCoreDataClass().editData(localData: localData.first!, uid: iAD.uid,loginStatus: "loggedIn" ,context: managedObjectContext)
                    }
                    
                    let docRef = db.collection("Users").document(iAD.uid)
                    let user = [
                        "username":iAD.userName,
                        "email": iAD.email,
                        "uid":iAD.uid,
                    ]
                    docRef.setData(user){ error in
                        if let error = error {
                           print("Error updating document: \(error)")
                       } else {
                           print("Document successfully updated!")
                           appState.rootViewId = UUID()
                       }
                    }
                }
            }
            NavigationLink(destination: LoginView(emailid: "", password: "")){
                HStack{
                    Text(strings.alreadyUser).foregroundColor(.black)
                    Text(strings.login).foregroundColor(Color("secondary_blue"))
                }.font(.custom("Poppins-Regular", size: 12))
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
            
        }
        .frame(minHeight: 0, maxHeight: .infinity,alignment: .top)
        .padding()
        .background(Color("light_background"))
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
    
//    @State
//        private var editingTextFieldUserName = false {
//            didSet {
//                guard editingTextFieldUserName != oldValue else {
//                    return
//                }
//                if editingTextFieldUserName {
//                    editingTextFieldPassword = false
//                    editingTextFieldEmail = false
//                } else {
//                    userNameViewModel.validateUserName()
//                }
//            }
//        }
//
//    @State
//        private var editingTextFieldPassword = false {
//            didSet {
//                guard editingTextFieldPassword != oldValue else {
//                    return
//                }
//                if editingTextFieldPassword {
//                    editingTextFieldUserName = false
//                    editingTextFieldEmail = false
//                } else {
//                    passwordViewModel.validatepassword()
//                }
//            }
//        }
//
//    @State
//        private var editingTextFieldEmail = false {
//            didSet {
//                guard editingTextFieldEmail != oldValue else {
//                    return
//                }
//                if editingTextFieldEmail {
//                    editingTextFieldPassword = false
//                    editingTextFieldUserName = false
//                } else {
//                    userNameViewModel.validateUserName()
//                }
//            }
//        }
//
//    @State
//        private var editingTextFieldPhone = false {
//            didSet {
//                guard editingTextFieldPhone != oldValue else {
//                    return
//                }
//                if editingTextFieldPhone {
//                    editingTextFieldUserName = false
//                } else {
//                    passwordViewModel.validatepassword()
//                }
//            }
//        }
    
//    @StateObject
//        private var userNameViewModel = MaterialDesignTextFieldModel()
//    @StateObject
//        private var passwordViewModel = MaterialDesignTextFieldModel()
//    @StateObject
//        private var emailIdViewModel = MaterialDesignTextFieldModel()
//    @StateObject
//        private var phoneViewModel = MaterialDesignTextFieldModel()
}

//struct RegisterView_Previews: PreviewProvider {
//    static var previews: some View {
//    }
//}
