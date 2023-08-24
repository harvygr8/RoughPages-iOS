//
//  ProfileView.swift
//  movietime
//
//  Created by Pranjal Chaudhari on 27/04/23.
//

import SwiftUI

struct ProfileView: View {
    let strings = Strings()
    let db = FirebaseController.firebaseController.firestore
    let iAD = InAppDetails.inAppDetails
    let fstore = FirebaseController.firebaseController.storage
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.uid, order: .reverse)]) var localData:
        FetchedResults<LocalData>
    @State var downloadUrl = ""
    @State private var isActive = false
    @State private var logoutIsActive = false
    @EnvironmentObject var appState: InAppDetails
    @State var userName = ""
    @State var email = ""
    
    var body: some View {
        NavigationView{
            VStack{
                
                    Text(userName).font(.custom("Poppins-Medium", size: 24))
                    Text(email).font(.custom("Poppins-Regular", size: 18))
                    List{
                        HStack{
                            Text("Logout")
                            Spacer()
                            Image(systemName: "rectangle.portrait.and.arrow.right").foregroundColor(.black)
                            Image(systemName: "chevron.right")
                                          .resizable()
                                          .aspectRatio(contentMode: .fit)
                                          .frame(width: 7)
                                          .foregroundColor(Color("light_grey"))
                        }.onTapGesture {
                            for data in localData {
                                print("delete")
                                managedObjectContext.delete(data)
                            }
                            do{
                                try managedObjectContext.save()
                            }catch {
                                print("Error while logging out")
                            }
                            appState.rootViewId = UUID()
                        }
                        NavigationLink(destination: PageView(pagetype: .favoriteView, displayMode: .inline, navigationTitle: "Favorite Pages")){
                            HStack{
                                Text("Favorites")
                                Spacer()
                                Image(systemName: "heart")
                            }
                        }
                        NavigationLink(destination: PageView(pagetype: .sharedView, displayMode: .inline, navigationTitle: "Shared with me")){
                            HStack{
                                Text("Shared with me")
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                        NavigationLink(destination: PageView(pagetype: .privateView, displayMode: .inline, navigationTitle: "Private pages")){
                            HStack{
                                Text("Private pages")
                                Spacer()
                                Image(systemName: "eye")
                            }
                        }
                        NavigationLink(destination: PageView(pagetype: .collaborationView, displayMode: .inline, navigationTitle: "Collaborations")){
                            HStack{
                                Text("Collaborations")
                                Spacer()
                                Image(systemName: "person.badge.plus")
                            }
                        }
                    }
            }.navigationViewStyle(StackNavigationViewStyle())
            .navigationTitle(Text("Profile"))
            .navigationBarTitleDisplayMode(.automatic)
            .frame(minWidth: 0,maxWidth: .infinity,minHeight: 0, maxHeight: .infinity,alignment: .top)
                //.background(Color("light_background"))
                .padding()
                .background(Color("light_background"))
                .onAppear{
                    let docRef = db.collection("Users").document(iAD.uid)

                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                            print("Document data: \(dataDescription)")
                            if let data = document.data() {
                               print("data", data)
                                iAD.userName = data["username"] as? String ?? ""
                                iAD.email = data["email"] as? String ?? ""
                                userName = iAD.userName
                                email = iAD.email
                           }
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
