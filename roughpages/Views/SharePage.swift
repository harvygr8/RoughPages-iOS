//
//  SharePage.swift
//  roughpages
//
//  Created by Harvinder Laliya on 05/05/23.
//

import SwiftUI
import WrappingHStack

struct SharePage: View {
    @Environment(\.dismiss) var dismiss
    @Binding var emails: Set<String>
    @State var emailValue = ""
    let db = FirebaseController.firebaseController.firestore
    let iAD = InAppDetails.inAppDetails
    let page: PageModel

    var body: some View {
        VStack{
            Text("Share with")
            TextField("Email Id",text: $emailValue).textCase(.lowercase)
                .onSubmit {
                emails.insert(emailValue)
                emailValue = ""
            }.textFieldStyle(.roundedBorder)
            WrappingHStack(emails.sorted()) { model in
              Text(model)
                    .padding(.all, 5)
                    .font(.body)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
            }
            Spacer()
            RoundedRectangleBtn(title: "Share").onTapGesture {
                for email in emails {
                    print("Checking email: \(email)")
                    db.collection("Users").whereField("email", isEqualTo: email).limit(to: 1).getDocuments{
                        (querySnapshot, err) in
                        if let err = err {
                            print("Error getting document with email: \(err)")
                        }else{
                            guard let documents = querySnapshot?.documents else{
                                print("No documents with email")
                                return
                            }
                            
                            let _ = documents.map{(queryDocumentSnapshot) -> UserModel in
                                let data = queryDocumentSnapshot.data()
                                let uid = data["uid"] as? String ?? ""
                                let username = data["username"] as? String ?? ""
                                let email = data["email"] as? String ?? ""
                                print("UID is \(uid)")
                                db.collection("Users").document(uid).getDocument{(document, error) in
                                    if let document = document, document.exists {
                                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                        //print("Document data: \(dataDescription)")
                                        if let data = document.data() {
                                           //print("data", data)
                                            var favs = document["sharedWithMe"] as? [String] ?? []
                                            favs.append(page.path)
                                            let data = [
                                                "sharedWithMe": favs
                                            ] as [String : Any]
                                            print("shared path: \(data)")
                                            let docRef = db.collection("Users").document(uid)
                                            docRef.setData(data,merge: true){ error in
                                                if let error = error {
                                                   print("Error updating document: \(error)")
                                               } else {
                                                   print("Document successfully updated!")
                                                   return
                                               }
                                            }
                                       }
                                    } else {
                                        print("Document does not exist")
                                    }
                                }
                                return UserModel(uid: uid, email: email, username: username)
                            }
                        }
                    }
                }
                dismiss()
            }
        }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
        .padding()
    }
}
