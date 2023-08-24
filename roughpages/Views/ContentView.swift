//
//  ContentView.swift
//  roughpages
//
//  Created by Pranjal Chaudhari on 02/05/23.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

enum LoginStatus {
    case loading
    case loggedIn
    case loggedOut
    case newUser
}

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.uid, order: .reverse)]) var localData:
        FetchedResults<LocalData>
    
    var strings = Strings()
    @State private var loginStatus: LoginStatus = .loading
    let iAD = InAppDetails.inAppDetails
    @EnvironmentObject var appState: InAppDetails
    //let ld = InAppDetails.inAppDetails.localData
    //let mObj = InAppDetails.inAppDetails.managedObjectContext
    let db = FirebaseController.firebaseController.firestore
    let gSC = GoogleSignInController.googleSignInController
    
    @State var navigateAfterGoogleSignIn = false
    
    var body: some View {
        switch loginStatus{
        case .loading:
            VStack{
                ProgressView()
            }.onAppear{
            print("ALL: ")
            for data in localData {
                print(data.uid ?? "")
            }
            print("first: ")
            print(localData.first?.uid ?? "")
            print(localData.first?.loginStatus ?? "")
                
            if localData.first == nil {
                print("no local data available")
                LocalDataCoreDataClass().addData(uid: "", loginStatus: "newUser", context: managedObjectContext)
                loginStatus = .newUser
                return
            }
            iAD.uid = localData.first?.uid ?? ""
            iAD.loginStatus = localData.first?.loginStatus ?? ""
                
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if iAD.loginStatus == "loggedIn" {
                    print("Logged in user")
                    let docRef = db.collection("Users").document(iAD.uid)

                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                            print("Document data: \(dataDescription)")
                            if let data = document.data() {
                               print("data", data)
                                iAD.userName = data["username"] as? String ?? ""
                                iAD.email = data["email"] as? String ?? ""
                           }
                        } else {
                            print("Document does not exist")
                        }
                        print("username: \(iAD.userName)")
                    }
                    loginStatus = .loggedIn
                    LocalDataCoreDataClass().editData(localData: localData.first!, uid: iAD.uid, loginStatus: "loggedIn", context: managedObjectContext)
                }else if iAD.loginStatus == "loggedOut" {
                    print("Logged out user")
                    loginStatus = .loggedOut
                    LocalDataCoreDataClass().editData(localData: localData.first!, uid: iAD.uid, loginStatus: "loggedOut", context: managedObjectContext)
                } else{
                    print("New user")
                    loginStatus = .newUser
                    LocalDataCoreDataClass().editData(localData: localData.first!, uid: iAD.uid, loginStatus: "newUser", context: managedObjectContext)
                }
            }
            
        }
        case .loggedIn:
            MainAppView()
        case .loggedOut:
            NavigationView{
                RegisterView(username: "", emailid: "", password: "")
            }.navigationViewStyle(StackNavigationViewStyle())
        case .newUser:
            NavigationView{
                WelcomeView()
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
