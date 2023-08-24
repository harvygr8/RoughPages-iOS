//
//  LoginView.swift
//  movietime
//
//  Created by Harvinder Laliya on 27/04/23.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

struct LoginView: View {
    let strings = Strings()
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.uid, order: .reverse)]) var localData:
        FetchedResults<LocalData>
    @EnvironmentObject var appState: InAppDetails
    @State private var isActiveLogin = false
    @State private var isActiveGoogle = false
    @State private var state: Int? = 0
    let auth = FirebaseController.firebaseController.auth
    let db = FirebaseController.firebaseController.firestore
    let iAD = InAppDetails.inAppDetails
    let gSC = GoogleSignInController.googleSignInController
    @State var emailid : String
    @State var password : String
    
    
    var body: some View {
        VStack{
            HStack{
                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage()).resizable()
                    .frame(width: 100,height: 100,alignment: .leading).cornerRadius(10, corners: .allCorners)
            }.frame(maxWidth: .infinity,alignment: .leading).padding(.bottom)
            Text(strings.login).font(.custom("Poppins-Medium", size: 24)).frame(minWidth: 0,maxWidth: .infinity,alignment: .leading).padding(.bottom,8)
            Text(strings.loginSubtitle).font(.custom("Poppins-Light", size: 14)).frame(minWidth: 0,maxWidth: .infinity,alignment: .leading)
            
            TextField(strings.email,text: $emailid)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .border(Color(UIColor.separator))
                .cornerRadius(2)
                .padding(.top,6)
            SecureField(strings.password,text: $password)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .border(Color(UIColor.separator))
                .cornerRadius(2)
                .padding(.top,12)
            Spacer()
            RoundedRectangleBtn(title: strings.login).padding(.bottom,5).onTapGesture {
                auth.signIn(withEmail: emailid, password: password){(result,error) in
                    if let error = error as NSError? {
                        guard let errorCode = AuthErrorCode.Code(rawValue: error.code) else {
                            print("there was an error logging in but it could not be matched with a firebase code")
                            return
                        }
                        print("Failed to sign in user due to error: ",errorCode.rawValue)
                        return
                    }
                    print("Successfully signed in user with account ID: ",result?.user.uid ?? "")
                    iAD.uid = result?.user.uid ?? ""
                    iAD.email = emailid
                    print("Successfully signned in user with account ID: ",iAD.uid)
                    
                    if localData.isEmpty || localData.first == nil {
                        LocalDataCoreDataClass().addData(uid: iAD.uid,loginStatus: "loggedIn", context: managedObjectContext)
                    }else{
                        LocalDataCoreDataClass().editData(localData: localData.first!, uid: iAD.uid,loginStatus: "loggedIn", context: managedObjectContext)
                    }
                    
                    let docRef = db.collection("Users").document(iAD.uid)

                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                            print("Document data: \(dataDescription)")
                            if let data = document.data() {
                               print("data", data)
                                iAD.userName = data["username"] as? String ?? ""
                                iAD.email = data["email"] as? String ?? ""
                                appState.rootViewId = UUID()
                           }
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
            }
            VStack{
                Text(strings.noAccount)
                NavigationLink(destination: RegisterView(username: "", emailid: "", password: "")){
                    Text(strings.registerNow).foregroundColor(Color("secondary_blue"))
                }
            }.font(.custom("Poppins-Regular", size: 12))
            HStack{
                VStack{
                    Divider()
                }
                Text("OR").font(.custom("Poppins-Regular", size: 10)).foregroundColor(Color("light_grey"))
                VStack{
                    Divider()
                }
            }.padding(.bottom,5)
            NavigationLink(destination: ContentView(),isActive: $isActiveGoogle){
                GoogleSignInButton()
            }.simultaneousGesture(TapGesture().onEnded{
                //gSC.signIn()
            })
            
        }
        .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0, maxHeight: .infinity,alignment: .top)
        .padding()
        .background(Color("light_background"))
    }
    

    
//    @State
//        private var editingTextFieldUserName = false {
//            didSet {
//                guard editingTextFieldUserName != oldValue else {
//                    return
//                }
//                if editingTextFieldUserName {
//                    editingTextFieldPassword = false
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

}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        //LoginView()
//    }
//}
