//
//  PageDetailView.swift
//  roughpages
//
//  Created by Harvinder Laliya on 04/05/23.
//

import SwiftUI
import MarkdownUI
import WrappingHStack

struct PageDetailView: View {
    let page: PageModel
    let pageType: PageViewType
    let db = FirebaseController.firebaseController.firestore
    let iAD = InAppDetails.inAppDetails
    @State var showShareSheet = false
    @State var showCollaboratorSheet = false
    @State var shareEmails: Set<String> = []
    @State var collaborators: Set<String> = []
    @State var update = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ScrollView(.vertical,showsIndicators: false){
            VStack{
                HStack{
                    Markdown{
                        Heading(.level1){
                            page.title
                        }
                    }
                }.frame(minWidth: 0,maxWidth: .infinity,alignment: .leading)
                HStack{
                    Text(page.timeStamp)
                }.frame(minWidth: 0,maxWidth: .infinity,alignment: .leading)
                HStack{
                    Text("By \(page.username)").padding(.top,2)
                }.frame(minWidth: 0,maxWidth: .infinity,alignment: .leading)
                WrappingHStack(page.tags) { model in
                  Text(model)
                        .padding(.all, 5)
                        .font(.body)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(5)
                }
                HStack{
                    Markdown(page.description)
                        .markdownTextStyle(\.code) {
                          FontFamilyVariant(.monospaced)
                          FontSize(.em(0.85))
                          ForegroundColor(.purple)
                          BackgroundColor(.purple.opacity(0.25))
                        }.markdownBlockStyle(\.blockquote) { configuration in
                            configuration.label
                              .padding()
                              .markdownTextStyle {
                                FontCapsVariant(.lowercaseSmallCaps)
                                FontWeight(.semibold)
                                BackgroundColor(nil)
                              }
                              .overlay(alignment: .leading) {
                                Rectangle()
                                  .fill(Color.teal)
                                  .frame(width: 4)
                              }
                              .background(Color.teal.opacity(0.5))
                          }
                }.frame(minWidth: 0,maxWidth: .infinity,alignment: .leading)
            }.frame(minWidth: 0,maxWidth: .infinity,alignment: .top)
                .navigationBarTitle("",displayMode: .inline)
                .padding()
                //.navigationBarHidden(true)
        }.frame(minWidth: 0,maxWidth: .infinity,minHeight: 0,maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu {
                        if page.collaborators.contains(iAD.email) {
                            NavigationLink(destination: AddPageView(update:$update,page: page, editType: .editPage)){
                                Label("Edit",systemImage: "square.and.pencil")
                            }
                        }
                        if page.uid == iAD.uid {
                            Button(action: {
                                //showAddTagSheet = true
                                if pageType == PageViewType.mainView {
                                    db.collection("Pages").document(page.docId).delete(){ err in
                                        if let err = err {
                                            print("Error removing document: \(err)")
                                        } else {
                                            print("Document successfully removed!")
                                        }
                                        dismiss()
                                    }
                                }
                                if pageType == .favoriteView {
                                    db.collection("Users").document(iAD.uid).collection("favorites").document(page.docId).delete(){ err in
                                        if let err = err {
                                            print("Error removing document: \(err)")
                                        } else {
                                            print("Document successfully removed!")
                                        }
                                        dismiss()
                                    }
                                }
                                if pageType == .sharedView {
                                    db.collection("Users").document(iAD.uid).collection("sharedWithMe").document(page.docId).delete(){ err in
                                        if let err = err {
                                            print("Error removing document: \(err)")
                                        } else {
                                            print("Document successfully removed!")
                                        }
                                        dismiss()
                                    }
                                }
                                if pageType == .privateView {
                                    db.collection("Users").document(iAD.uid).collection("private").document(page.docId).delete(){ err in
                                        if let err = err {
                                            print("Error removing document: \(err)")
                                        } else {
                                            print("Document successfully removed!")
                                        }
                                        dismiss()
                                    }
                                }
                            }){
                                Label("Delete",systemImage: "trash")
                            }
                        }
                        Button(action: {
                            showShareSheet = true
                        }){
                            Label("Share",systemImage: "square.and.arrow.up")
                        }
                        if page.uid == iAD.uid{
                            Button(action: {
                                showCollaboratorSheet = true
                            }){
                                Label("Add collaborator",systemImage: "person.badge.plus")
                            }
                        }
                        Button(action: {
                            db.collection("Users").document(iAD.uid).getDocument{(document, error) in
                                if let document = document, document.exists {
                                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                    print("Document data: \(dataDescription)")
                                    if let data = document.data() {
                                       print("data", data)
                                        var favs = document["favorites"] as? [String] ?? []
                                        favs.append(page.path)
                                        let data = [
                                            "favorites": favs
                                        ] as [String : Any]
                                        let docRef = db.collection("Users").document(iAD.uid)
                                        docRef.setData(data,merge: true){ error in
                                            if let error = error {
                                               print("Error updating document: \(error)")
                                           } else {
                                               print("Document successfully updated!")
                                           }
                                        }
                                   }
                                } else {
                                    print("Document does not exist")
                                }
                            }
                            
                            
                        }){
                            Label("Favorite",systemImage: "heart")
                        }
                        
                    }label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet){
                SharePage(emails: $shareEmails,page: page)
            }.sheet(isPresented: $showCollaboratorSheet){
                AddCollaboratorPage(emails: $collaborators, page: page)
            }
            .onAppear{
                shareEmails = page.sharedWith
                collaborators = page.collaborators
                print("Collaborators: \(collaborators)")
                print("my email: \(iAD.email)")
                print("page uid: \(page.uid)")
                print("my uid : \(iAD.uid)")
                if update {
                    print("Updated des: ")
                    dismiss()
                }
            }
    }
}

struct PageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PageDetailView(page: PageModel(uid: "UID", email: "Email", username: "Username", description: "description", title: "title", tags: ["tag"], timeStamp: "time",isPrivate: false, collaborators: ["colab"],sharedWith: ["share"],favorites: ["fav"],docId: "docId", path: "path"),pageType: PageViewType.mainView)
    }
}
